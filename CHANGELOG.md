### Unreleased

* Drop support for Rails 5.2.
* Drop support for Ruby 2.5 and 2.6.

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
