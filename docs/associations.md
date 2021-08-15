## State of testing

This table shows the test coverage of different configuration options with
relation to each association type together with some notes about behaviour.
Associated instances in a duplicated instance may be blank, copied from the
original instance or duplicated as new instances.

|                        | `has_one`                       | `has_many`                        | `has_and_belongs_to_many`         |
|---|---|---|---|
| not enabled            | Yes (association is nil)        | No                                | Yes (associations are empty)      |
| enabled                | Yes (association is duplicated) | Yes (associations are duplicated) | Yes (associations are copied)     |
| blank assocation       | Yes (assocation is nil          | No                                | No                                |
| nullify                | Yes (association is nil         | No                                | No                                |
| preprocessing          | Yes                             | Yes                               | No                                |
| not recognized         | Yes (association is nil)        | Yes                               | Yes (associations are empty)      |
| with `clone`           | N/A                             | N/A                               | Yes (associations are duplicated) |
| STI                    | | | |
| propagate              | Yes                             | No                                | No                                |
| no propagate           | Yes                             | No                                | No                                |
| set on STI table       | Yes                             | No                                | No                                |
| `through`              | | | |
| enabled on join table  | Yes (association is duplicated) | Yes (associations are copied)     | No                                |
| not enabled on join    | Yes (association is nil)        | Yes (associations are blank)      | No                                |
| not recognized on join | Yes (association is nil)        | Yes (associations are blank)      | No                                |
| with `clone`           | N/A                             | Yes (associations are duplicated) | No                                |
