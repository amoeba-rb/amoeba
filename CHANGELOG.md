### 3.4.0

* Update test matrix for current version for Ruby and Rails. Drop support for Rails versions 5.2 and 6.0, and Ruby 2.5, 2.6 and 2.7. [https://github.com/amoeba-rb/amoeba/pull/120 and https://github.com/amoeba-rb/amoeba/pull/124]
* Notes on contributing. Github Actions for automate tests. [https://github.com/amoeba-rb/amoeba/pull/124]
* Fix tests for Active Record after 7.1. [https://github.com/amoeba-rb/amoeba/pull/127]
* Refactor tests. [https://github.com/amoeba-rb/amoeba/pull/130]
* Allow `nullify` to accept an `:if` condition. `Config#null_fields` is now a Hash of field names to options rather than an Array of field names, for consistency with `includes` and `excludes`; code reading it directly should use `null_fields.keys`. [https://github.com/amoeba-rb/amoeba/pull/134] Thanks @bvicenzo.

#### Breaking change

Internally the configuration of `null_fields` is now stored as a `Hash` instead of an `Array`. This could cause failures if you access the `config` directly. For example;

```ruby
# test.rb
require_relative 'config/environment'

class Post < ActiveRecord::Base
  amoeba do
    enable
    nullify :topic_id
    nullify :likes
  end
end

config = Post.amoeba

pp config.null_fields
pp config.null_fields.first
pp config.null_fields.map(&:to_s)
pp config.null_fields << :extra
```

With previous versions of `amoeba` the output of this will be;

```
[:topic_id, :likes]
:topic_id
["topic_id", "likes"]
[:topic_id, :likes, :extra]
```

With the new version of `amoeba` some of these command execute successfully with changed output and the final line fails with an exception;

```
{topic_id: {}, likes: {}}
[:topic_id, {}]
["[:topic_id, {}]", "[:likes, {}]"]
test.rb:18:in '<main>': undefined method '<<' for an instance of Hash (NoMethodError)

pp config.null_fields << :extra
                      ^^
Did you mean?  <
```

### 3.3.0

* Move test pipelines from Travis to Github Actions.
* `include_field` and `exclude_field` configuration options have been removed.
  These had been marked as deprecated in version 2 and replaced by
  `include_association` and `exclude_association`.
* Official support dropped for Rails 5.1 and earlier. Test pipelines now run
  for Rails 5.2 up to 7.0 as well as the current development head.
* Official support dropped for Ruby 2.4 and earlier. Test pipelines now run for
  Ruby 2.5 up to 3.2 as well as the current development head.
* Ambiguous 'BSD' license replaced with 'BSD 2-Claus "Simplified" License'.
* Fix copy-and-paste mistake in documenation. Thanks @budu.
* Use lazy load hooks to extend ActiveRecord::Base. This is to ensure
  compatibility with Factory Bot Rails 6.4.0. Thanks @tagliala.
