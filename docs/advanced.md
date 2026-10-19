# Advanced usage

## Recursive copies

Amoeba descends through a graph only where each record's model configuration allows it. Configure every level that owns children.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order

  amoeba { enable }
end

class LineItem < ApplicationRecord
  belongs_to :order, inverse_of: :line_items
  has_many :adjustments, inverse_of: :line_item

  amoeba { enable }
end

class Adjustment < ApplicationRecord
  belongs_to :line_item, inverse_of: :adjustments
end
```

Duplicating an order duplicates line items, and each line item duplicates adjustments. Keep the association graph acyclic for the associations Amoeba follows; a circular enabled graph can recurse indefinitely.

## Through associations

For `has_many :through`, Amoeba follows the join model as a normal `has_many` association and normally reuses associated target rows. When `clone` is set for the through association, Amoeba duplicates target rows and avoids duplicating the original join association directly.

```ruby
class Playlist < ApplicationRecord
  has_many :playlist_entries, inverse_of: :playlist
  has_many :tracks, through: :playlist_entries

  amoeba do
    enable
    clone :tracks
  end
end
```

Test this arrangement against the application's schema. Join models with validations or extra attributes should be configured explicitly and normally need `inverse_of` declarations.

## Single-table inheritance

Call `propagate` on an STI base class to apply its Amoeba configuration when duplicating subclasses.

```ruby
class Product < ApplicationRecord
  has_many :images

  amoeba do
    enable
    propagate
  end
end

class Book < Product
  amoeba do
    prepend title: 'Copy of '
  end
end
```

The inheritance style resolves conflicts between parent and child configuration:

- `:submissive` is the default. Parent settings are applied, then child settings are applied. Child configuration can replace list-based settings by supplying an array.
- `:relaxed` applies child settings first and then parent settings, so parent settings win where they conflict.
- `:strict` uses the propagated parent configuration only and ignores the child configuration.

A subclass can choose its own style with `raised`:

```ruby
class Book < Product
  amoeba do
    raised :strict
  end
end
```

## Custom base duplicate method

Use `through` when the initial object needs a different class or setup than Active Record's `dup` supplies.

```ruby
class ObjectPrototype < ApplicationRecord
  amoeba do
    through :become_real_object
  end

  def become_real_object
    dup.becomes(RealObject)
  end
end

class RealObject < ObjectPrototype
end
```

The configured method is invoked on the original record and must return an object that can receive the configured associations and attributes.

## Association-name remapping

Use `remapper` when a custom duplicate method changes the target class and the target class exposes different association names.

```ruby
class ObjectPrototype < ApplicationRecord
  has_many :subobject_prototypes

  amoeba do
    through :become_real_object
    remapper :remap_association
  end

  def become_real_object
    dup.becomes(RealObject)
  end

  def remap_association(name)
    :subobjects if name == :subobject_prototypes
  end
end

class RealObject < ObjectPrototype
  has_many :subobjects
end
```

The remapper receives a symbol and should return the target association symbol. Returning `nil` preserves the source name.

## Operational constraints

- `amoeba_dup` returns an unsaved graph. The caller decides when and how to persist it.
- Configuration is class-level mutable state. Define it while loading models, not in controller actions, jobs, or request-specific code.
- Callbacks receive unrestricted model objects. Keep `override` and `customize` small, deterministic, and free of persistence side effects.
- `regex` expects a non-nil string value. Use `customize` when a nullable or non-string field needs special handling.
- Validate the complete copied graph in the application's test suite, especially uniqueness validations, callbacks, database constraints, and custom association extensions.