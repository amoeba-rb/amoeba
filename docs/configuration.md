# Configuration reference

Call these methods inside a model's `amoeba` block. Configuration belongs to the class and applies to future calls to `amoeba_dup` for that model.

```ruby
class Post < ApplicationRecord
  amoeba do
    enable
  end
end
```

## Public entry points

### `record.amoeba_dup`

Returns an unsaved duplicate of `record`. It runs the configured `override` callbacks, association copying when enabled, then post-processing callbacks and attribute processors.

### `Model.amoeba { ... }`

Returns the model's configuration and evaluates the optional block against it. Calling it again adds to the existing configuration unless the particular DSL method replaces its own values.

### `Model.fresh_amoeba { ... }`

Replaces the model's configuration with a new configuration, then evaluates the optional block. This is mainly useful for tests or deliberate reconfiguration.

### `Model.reset_amoeba`

Replaces the model's configuration with the defaults. Unlike `fresh_amoeba`, it does not evaluate a supplied block.

## Association selection

### `enable` and `disable`

`enable` turns on association traversal using the default style: every supported association is followed. `disable` turns that traversal off. Attribute processors still run when configured.

### `include_association(name, if: method_name)`

Copies only named associations. Calling this method enables Amoeba and clears the exclusion list.

```ruby
amoeba do
  include_association :comments
  include_association :attachments, if: :duplicate_attachments?
end
```

The optional `if:` value is sent to the original record. It must name a method that returns a truthy or falsey value.

### `include_associations(*names)`

Convenience form for several inclusions:

```ruby
amoeba { include_associations :comments, :attachments }
```

### `exclude_association(name, if: method_name)`

Copies all supported associations except named ones. Calling this method enables Amoeba and clears the inclusion list. With `if:`, the named association is excluded only when the method on the original record is truthy.

```ruby
amoeba do
  exclude_association :audit_entries
  exclude_association :attachments, if: :large_export?
end
```

### `exclude_associations(*names)`

Convenience form for several exclusions.

### Array versus repeated values

For `include_association`, `exclude_association`, `clone`, and `recognize`, a single value adds to the current list. Passing an array replaces the current list for that directive.

```ruby
amoeba do
  include_association :comments
  include_association :tags             # comments and tags
  include_association [:attachments]    # attachments only
end
```

## Association behavior

### `clone(name)`

For a many-to-many relationship, duplicates the associated records instead of retaining references to existing records. This is most relevant to `has_and_belongs_to_many` and `has_many :through` associations.

```ruby
amoeba do
  enable
  clone :tags
end
```

### `recognize(name)`

Sets the association macros Amoeba may follow. Defaults are `:has_one`, `:has_many`, and `:has_and_belongs_to_many`.

```ruby
amoeba do
  enable
  recognize [:has_one, :has_and_belongs_to_many]
end
```

## Attribute processing

All attribute processors use Active Record's attribute access (`copy[field]`). They do not enable association traversal by themselves.

### `nullify(*fields)`

Sets attributes to `nil`.

```ruby
amoeba { nullify :published_at, :external_id }
```

### `set(attributes)`

Converts each configured value to a string and assigns it to the duplicate. This is useful for state-like string fields, including `false`, which becomes `"false"`.

```ruby
amoeba { set status: 'draft' }
```

### `prepend(attributes)` and `append(attributes)`

Interpolates the existing attribute value into a string with the configured prefix or suffix.

```ruby
amoeba do
  prepend title: 'Copy of '
  append slug: '-copy'
end
```

### `regex(attributes)`

Runs in-place `gsub!` on the copied attribute. Each value is a hash with `:replace` and `:with`.

```ruby
amoeba do
  regex contents: { replace: /dog/, with: 'cat' }
end
```

The target attribute must contain a mutable string. A `nil` or non-string value will raise when `gsub!` is called.

### `customize(callable)`

Runs one callable, or an array of callables, after association copying and built-in processors. Each callable receives the original and copied records.

```ruby
amoeba do
  customize ->(original, copy) do
    copy.owner_id = Current.user.id
    copy.source_post_id = original.id
  end
end
```

### `override(callable)`

Runs before association copying and built-in processors. It has the same arguments as `customize`.

```ruby
amoeba do
  override ->(_original, copy) { copy.status = 'draft' }
end
```

### Processing order

For a call to `amoeba_dup`, the order is:

1. `override` callbacks
2. association copying, when enabled
3. `nullify`
4. `set`
5. `prepend`
6. `append`
7. `regex`
8. `customize` callbacks

## Inheritance and transformation

### `propagate(style = :submissive)`

Enables inheritance of Amoeba configuration by STI subclasses. Styles are `:submissive` (default), `:relaxed`, and `:strict`; see [Advanced usage](advanced.md#single-table-inheritance).

### `raised(style = :submissive)`

Allows an STI child to choose the style it uses when inheriting a propagated parent configuration.

### `through(method_name)`

Uses a model instance method instead of `dup` to create the base duplicate. The method should return the duplicate Active Record object.

### `remapper(method_name)`

Uses a model instance method to translate an association name while assigning copied associations. The method receives the source association name as a symbol and should return the target association name, or `nil` to retain the original name.