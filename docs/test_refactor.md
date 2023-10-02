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

## Test setup

Most tests require a test Active Record model linked to a database table. In
the existing tests all the test models and database tables are created at the
start of the suite. For new tests the models and tables will be created as
required.

Ideally the tests will run in transactions but this causes the existing tests
in `spec/lib/amoeba_spec.rb` to fail. To configuration to enable running tests
in transactions can be found in `spec/spec_helper.rb` so that it can be used
for executing new tests locally.

`ActiveRecord::Base.connection` can be used to create the new tables. So, for
example;

```ruby
# These two lines are probably unecessary when the test is run in a transaction
ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
ActiveRecord::Base.connection.schema_cache.clear!

ActiveRecord::Base.connection.create_table :test_models do |t|
  t.integer :test_field, null: true
end
```

After the database table has been created the model can be created using
`stub_const`;

```ruby
stub_const 'TestModel', Class.new(ActiveRecord::Base)
```

and any configuration of the class can be given as a string to `class_eval`;

```ruby
TestModel.class_eval('amoeba { enable }')
```