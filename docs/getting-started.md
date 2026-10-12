# Getting started

## Installation

Add Amoeba to the application's Gemfile and bundle it:

```ruby
gem 'amoeba'
```

The gem depends on Active Record. Confirm supported Ruby and Active Record versions from the gemspec and CI matrix for the version being installed.

## Runnable example

The [`example/`](../example/) directory is a small, self-contained Active Record + SQLite3 app demonstrating recursive copying and the `prepend`/`nullify` directives:

```sh
cd example
bundle install
bundle exec ruby setup.rb    # creates the database and seeds sample data
bundle exec ruby example.rb  # duplicates a record and prints the result
```

## In detail

The definition of the `Survey` class in the above example is;

```ruby
class Survey < ActiveRecord::Base
  has_many :sections, inverse_of: :survey

  amoeba do
    enable
    prepend title: 'Copy of '
  end
end
```

When an instance of `Survey` is duplicated the Amoeba configuration does two things;
* `enable` causes child associations to be copied recursively
* `prepend` adds text to the string attribute

`Section` is defined as;

```ruby
class Section < ActiveRecord::Base
  belongs_to :survey, inverse_of: :sections
  has_many :questions, inverse_of: :section

  amoeba do
    enable
  end
end
```

As in `Survey`, `enable` causes child associations to be copied.

`Question` is defined as;

```ruby
class Question < ActiveRecord::Base
  belongs_to :section, inverse_of: :questions

  amoeba do
    nullify :response_count
  end
end
```

This class does not have child associations and so `enable` is not necessary. `nullify` results in the value to be set to nil in the copied instance.

## First duplication

With the classes set up as above;

```ruby
original = Survey.find(id)
copy = original.amoeba_dup
copy.save!
```

`copy` is a new `Survey` based on `original`. The title of `copy` is the same as the title of `original` with `Copy of ` prepended so, for example;

```ruby
original.title
=> "My first survey"
copy.title
=> "Copy of My first survey"
```

Any sections that `original` has are duplicated in `copy` as new instances of `Section`. The questions attached to each section are also duplicated and the values of `response_count` are set to `nil`. So, for example;

```ruby
original.sections.first.questions.first.question
=> "What is your favourite colour?"
original.sections.first.questions.first.response_count
=> 42
copy.sections.first.questions.first.question
=> "What is your favourite colour?"
copy.sections.first.questions.first.response_count
=> nil
```

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