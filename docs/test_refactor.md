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

The `amoeba_dup` method, which is how users will normally interact with Amoeba,
is in the `Amoeba::InstanceMethods` module so this is where these tests are to
be found. As there will be many such tests for various configuration options
they are broken up into separate files with names based on `instance_methods`
and with a double underscore preceeding the test grouping. So, for example,
tests of the indiscriminate, inclusive and exclusive styles are in
`spec/lib/amoeba/instance_methods__style_spec.rb`.

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

## Progress

### `amoeba/cloner.rb`

Tests exist for duplicating in the following situations;

* No modification.
* With a 'nullified' field; `nullify test_field`
* With a field to set to a default value; `set test_field: 'new value'`
* With a field to prepend; `prepend test_field: 'prefix'`
* With a field to append; `append test_field: 'suffix'`
* With a field modified by a regex; `regex test_field: { replace: /old/, with: 'new' }`

Preprocessing operations on fields that still need to be tested;

* With a field with customized preprocessing;
  * ```
      customize(lambda do |original, duplicate|
        return <new value based on original and duplicate>
      end)
    ```

Tests for various styles (indiscriminate, inclusive and exclusive) are found in
`spec/lib/amoeba/instance_methods__style_spec.rb`.
