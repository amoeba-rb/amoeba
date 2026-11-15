# Common recipes

## Copy a record with owned children

Use `enable` when the model owns ordinary `has_many` or `has_one` records that should be duplicated.

```ruby
class Invoice < ApplicationRecord
  has_many :line_items, inverse_of: :invoice

  amoeba do
    enable
    set state: 'draft'
    nullify :submitted_at
  end
end

class LineItem < ApplicationRecord
  belongs_to :invoice, inverse_of: :line_items
end

copy = Invoice.find(42).amoeba_dup
copy.save!
```

`copy.line_items` contains new records attached to `copy`; the source invoice and its line items are unchanged.

## Copy only selected associations

Use an inclusion list when a model has many relationships but only a few are meaningful in a duplicate.

```ruby
class Project < ApplicationRecord
  has_many :tasks
  has_many :documents
  has_many :audit_events

  amoeba do
    include_associations :tasks, :documents
  end
end
```

`audit_events` are not followed. An inclusion list is a safer default than copying every association for models with historical or externally-owned data.

## Retain shared tags

Many-to-many records are shared by default. This is appropriate for canonical tags, categories, roles, or reference records.

```ruby
class Article < ApplicationRecord
  has_and_belongs_to_many :tags

  amoeba do
    include_association :tags
  end
end
```

The copied article is associated with the original tag rows; no tag rows are created.

## Duplicate records behind a join

Use `clone` only when the related records belong exclusively to the duplicate.

```ruby
class Template < ApplicationRecord
  has_many :template_widgets
  has_many :widgets, through: :template_widgets

  amoeba do
    enable
    clone :widgets
  end
end
```

This creates new widget records and associates them with the copied template. Do not use it for shared catalog data: it will create independent copies.

## Make copied attributes unique

Preprocessors apply to the copied record before it is returned. Combine them to reset state and avoid uniqueness collisions.

```ruby
class Page < ApplicationRecord
  amoeba do
    prepend title: 'Copy of '
    append slug: '-copy'
    nullify :published_at
    set status: 'draft'
    regex body: { replace: /\bcurrent\b/i, with: 'previous' }
  end
end
```

For complex uniqueness rules, use `customize` and generate the final value in application code.

## Conditional relationships

Conditions are methods on the original record. They control only the named association; they do not switch the overall inclusion/exclusion strategy.

```ruby
class Report < ApplicationRecord
  has_many :attachments

  amoeba do
    include_association :attachments, if: :attachments_can_be_copied?
  end

  def attachments_can_be_copied?
    attachments.sum(:byte_size) < 25.megabytes
  end
end
```

## Record provenance with `customize`

`customize` is the right place for application-specific metadata because it receives both records.

```ruby
class Dashboard < ApplicationRecord
  amoeba do
    customize ->(original, copy) do
      copy.source_dashboard_id = original.id
      copy.created_by_id = Current.user.id
    end
  end
end
```

Keep callbacks deterministic and avoid saving records inside them. Amoeba builds the graph first; the caller owns the persistence boundary.