# Getting started

## Installation

Add Amoeba to the application's Gemfile and bundle it:

```ruby
gem 'amoeba'
```

The gem depends on Active Record. Confirm supported Ruby and Active Record versions from the gemspec and CI matrix for the version being installed.

## First duplication

Given a post with comments, enable Amoeba on every model whose child associations should be copied recursively.

```ruby
class Post < ApplicationRecord
  has_many :comments, inverse_of: :post

  amoeba do
    enable
    prepend title: 'Copy of '
  end
end

class Comment < ApplicationRecord
  belongs_to :post, inverse_of: :comments
end

original = Post.find(params[:id])
copy = original.amoeba_dup
copy.save!
```

`copy` is a new, unsaved `Post`. With this configuration it has a copied title and new, unsaved comment records attached to it. Persisting `copy` saves the graph through Active Record's normal association behavior.

## What Amoeba copies

When enabled without an association list, Amoeba follows these Active Record association macros:

- `has_one`
- `has_many`
- `has_and_belongs_to_many`

`belongs_to` associations are not followed. A copied child normally has its foreign key cleared and is attached to the copied parent.

For `has_and_belongs_to_many` and `has_many :through`, Amoeba retains the relationship to the existing associated records by default. Use `clone` when those associated records themselves must be duplicated; see [Common recipes](examples.md).

## Saving and validations

The object graph is intentionally built before the parent has an ID. If a copied child validates the presence of its parent, declare inverses so Active Record can connect the in-memory objects:

```ruby
class Author < ApplicationRecord
  has_many :posts, inverse_of: :author
end

class Post < ApplicationRecord
  belongs_to :author, inverse_of: :posts
  validates :author, presence: true
end
```

Use `save!` when a failed validation should be surfaced immediately. `amoeba_dup` does not persist records, bypass validations, or prevent database uniqueness violations. Configure `nullify`, `set`, `prepend`, `append`, `regex`, or `customize` to make the duplicate valid for the application.

## Selecting associations

Choose one association-selection style per model:

```ruby
# Copy every supported association.
amoeba { enable }

# Copy only comments and tags.
amoeba { include_associations :comments, :tags }

# Copy every supported association except audit_entries.
amoeba { exclude_association :audit_entries }
```

`include_association` and `exclude_association` enable Amoeba automatically. An inclusion list takes precedence over an exclusion list when both have been configured.