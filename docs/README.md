# Amoeba documentation

Amoeba extends Active Record models with `amoeba_dup`, a configurable deep-duplication operation for records and their associations.

## Guides

- [Getting started](getting-started.md): installation, the duplication lifecycle, and a first model.
- [Configuration reference](configuration.md): every public method available inside an `amoeba` block.
- [Common recipes](examples.md): typical application configurations.
- [Advanced usage](advanced.md): recursion, `has_many :through`, STI, custom duplicate methods, and remapping.
- [Contributing](contributing.md): development and pull-request guidance.
- [Test refactor](test_refactor.md): historical notes on the test-suite restructuring.

## Core idea

`record.amoeba_dup` creates an unsaved Active Record object. Amoeba starts with the record's normal `dup` behavior, optionally follows configured associations, and applies configured attribute changes. Save the returned record when it is valid for the application's schema and validations.

```ruby
copy = post.amoeba_dup
copy.save!
```

Associations are configured on the model class, not on individual calls. The configuration is mutable class state, so configure models during class loading. Do not modify `Post.amoeba` in request handling; that change affects concurrent requests using the same process.