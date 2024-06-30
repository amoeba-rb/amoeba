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

## regex

To do

## override

To do

## customize

To do
