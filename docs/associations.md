## State of testing

This table shows the test coverage of different configuration options with
relation to each association type together with some notes about behaviour.
Associated instances in a duplicated instance may be blank, copied from the
original instance or duplicated as new instances.

|                        | `has_one`                       | `has_many`                        | `has_and_belongs_to_many`         |
|---|---|---|---|
| not enabled            | Yes (association is nil)        | Yes (associations are empty)      | Yes (associations are empty)      |
| enabled                | Yes (association is duplicated) | Yes (associations are duplicated) | Yes (associations are copied)     |
| blank assocation       | Yes (assocation is nil)         | Yes (associations are empty)      | No                                |
| nullify                | Yes (pending, see below)        | Yes (pending, see below)          | No                                |
| preprocessing          | Yes                             | Yes                               | No                                |
| not recognized         | Yes (association is nil)        | Yes                               | Yes (associations are empty)      |
| with `clone`           | N/A                             | N/A                               | Yes (associations are duplicated) |
| STI                    | | | |
| propagate              | Yes                             | Yes                               | No                                |
| no propagate           | Yes                             | Yes                               | No                                |
| set on STI table       | Yes                             | Yes                               | No                                |
| `through`              | | | |
| enabled on join table  | Yes (association is duplicated) | Yes (associations are copied)     | No                                |
| not enabled on join    | Yes (association is nil)        | Yes (associations are blank)      | No                                |
| not recognized on join | Yes (association is nil)        | Yes (associations are blank)      | No                                |
| with `clone`           | N/A                             | Yes (associations are duplicated) | No                                |

### Pending tests

Some tests are 'pending' as the particular configuration does not currently
work. As such, the correct behaviour is to be decided but the pending tests
assume the following behaviour:

| Configuration | Expected behaviour | Actual behaviour |
|---|---|---|
| `has_one` association with `nullify` | Associated record of duplicate will be nil | `ActiveModel::MissingAttributeError` exception |
| `has_many` association with `nullify` | Associated records of duplicate will be empty | `ActiveModel::MissingAttributeError` exception |
