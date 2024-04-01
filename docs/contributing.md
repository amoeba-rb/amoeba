# Contributing to Amoeba

Contributations to this project are welcome. The current needs are;

* More structured documentation
* [Refactoring tests](test_refactor.md)
* Identifying and prioritising features that could be implemented from the long list of issues
* Reviewing of pull requests

## Some notes regarding pull requests

When making code changes please include unit tests for any new code and ensure that all tests pass for supported versions of Ruby and Active Record. These tests are run automatically.

Note that the tests are also run automatically for the current development branches of Ruby and Active Record. It is not necessary for all tests to pass in these cases. However;

* Please try at least for new tests in the PR to pass unless there is an identifiable issue in the development version of either Ruby or Active Record.
* For any new failures you see please consider raising an issue to have it fixed.