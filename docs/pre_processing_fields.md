# Pre-Processing Fields

## nullify

To do

## prepend

To do

## append

To do

## set

Set a field to a given value.

```ruby
  amoeba do
    set string_field: 'default string value'
    set integer_field: 99
    set boolean_field: false
  end
```

The field may be set to the return value of a lambda, so to set a field to the
current time:

```ruby
  amoeba do
    set datetime_field: ->() { Time.now }
  end
```

Keyword parameters passed to the `amoeba_dup` command can also be used:

```ruby
  amoeba do
    set string_field: ->(str_arg:) { str_arg }
    set integer_field: ->(int_arg:) { int_arg }
    set combined_field: ->(str_arg:, int_arg: 33, other_arg: 'default') { "#{str_arg} - #{int_arg} - #{other_arg}" }
  end

new_item = item.amoeba_dup(str_arg: 'new string', int_arg: 45)
# => new_item.string_field = 'new_string'
# => new_item.integer_field = 99
# => new_item.combined_field = 'new_string - 99 - default'
```


## regex

To do

## override

To do

## customize

To do
