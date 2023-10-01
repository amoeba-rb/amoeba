# Test refactor

## Motivation

This gem has been unmaintained for some time but is still used. This could
cause problems if it becomes incompatible with new versions of Active Record.
Additionally, there are lots of issues that have been raised and there could be
other features of Active Record that should be supported. However, the tests
not easy to understand as they generally comprise a large setup of data
followed by multiple expectations with no indication of their purpose. A better
structure for the tests would allow for making changes with more confidence.

## Plan

All of the tests are currently in `spec/lib/amoeba_spec.rb`. New tests will be
created to mimic the modules so, for example;

* `spec/lib/amoeba/cloner_spec.rb` to test the `Amoeba::Cloner` class.
* `spec/lib/amoeba/macros/has_many_spec.rb` to test the
  `Amoeba::Macros::HasMany` module.
