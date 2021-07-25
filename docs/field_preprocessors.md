## Field Preprocessors

Fields can be configured with preprocessors to modify the value in a duplicate.
These are:

* Nullify
* Set
* Prepend and append
* Regex
* Customize and override

More details of each of these are given below.

With each preprocessor, multiple fields can be configured together or
separately so, for example, the following are equivalent:

```ruby
amoeba do
  enable
  prepend title: 'Copy of ', contents: 'Copied contents: '
end

# or

amoeba do
  enable
  prepend title: 'Copy of '
  prepend contents: 'Copied contents: '
end
```

Multiple preprocessing filters can be applied to a field, such as:

```ruby
amoeba do
  enable
  prepend title: 'Copy of '
  append title: ' <- copied'
  regex title: { replace: /cat/, with: 'dog' }
end
```

**Note:** The preprocessing directives do not automatically enable the copying
of associated child records. If only preprocessing directives are used and you
do want to copy child records and no `include_association` or
`exclude_association` list is provided, you must still explicitly enable the
copying of child records by calling the enable method from within the amoeba
block on your model.

### Nullify

A field in a duplicate can be set to `nil` with the following configuration:

```ruby
class Post < ActiveRecord::Base
  amoeba do
    enable
    nullify :date_published
  end
end
```

#### Example

```ruby
irb> original = Post.create(date_published: '19 March 2021')
irb> original.date_published
=> Fri, 19 Mar 2021
irb> copy = original.amoba_dup
irb> copy.date_published
=> nil
```

A `belongs_to` association can also be removed by applying `nullify` to the id
field:

```ruby
class Post < ActiveRecord::Base
  belongs_to :topic

  amoeba do
    enable
    nullify :topic_id
  end
end
```

### Set

The value of a field can be replaced in a duplicate with a set value:

```ruby
class Post < ActiveRecord::Base
  amoeba do
    enable
    set state_tracker: "open_for_editing", counter: 0
  end
end
```

#### Example

```ruby
irb> original = Post.create(state_tracker: 'completed', counter: 10)
irb> original.state_tracker
=> "completed"
irb> original.counter
=> 10
irb> copy = original.amoba_dup
irb> copy.state_tracker
=> "open_for_editing"
irb> copy.counter
irb> 0
```

### Prepend and append

A string may be added to the beginning or end of a field:

```ruby
class Post < ActiveRecord::Base
  amoeba do
    enable
    prepend title: "Copy of "
    append contents: " (New version)"
  end
end
```

**Note:** `prepend` and `append` can only be used for string and text data
types.

#### Example

```ruby
irb* original = Post.create(
irb*   title: 'Lorem ipsum dolor sit amet.',
irb*   contents: 'Nulla pharetra porta metus id porttitor.'
irb> )
irb> original.title
=> "Lorem ipsum dolor sit amet."
irb> original.contents
=> "Nulla pharetra porta metus id porttitor."
irb> copy = original.amoeba_dup
irb> copy.title
=> "Copy of Lorem ipsum dolor sit amet."
irb> copy.contents
=> "Nulla pharetra porta metus id porttitor. (New version)"
```

### Regex

A string or text field can be modified by replacing a substring matching a
regular expression:

```ruby
class Post < ActiveRecord::Base
  amoeba do
    enable
    regex contents: {replace: /[aeiou]/, with: '?'}
  end
end
```

**Note:** `regex` can only be used for string and text data types.

#### Example

```ruby
irb> original = Post.create(contents: 'Nulla pharetra porta metus id porttitor.')
irb> original.contents
=> "Nulla pharetra porta metus id porttitor."
irb> copy = original.amoeba_dup
irb> copy.contents
=> "N?ll? ph?r?tr? p?rt? m?t?s ?d p?rtt?t?r."
```

### Customize and override

One or more lambdas can be used to make customized modifications to field
after other preprocessing (with `customize`) or before (with `override`).

Both `customize` and `override` take as an argument a single lambda or an
array of multiple lambdas which are processed in order. Each lambda takes two
arguments; the original and the duplicate record.

```ruby
class Post < ActiveRecord::Base
  amoeba do
    enable
    append title: ' <<<', contents: ' ???'

    customize(
      [
        lambda { |original_post,new_post|
          # `(counter)` will be added after the '<<<' is appended to the title
          new_post.title += " (#{original_post.counter})"
        },
        lambda { |original_post, new_post|
          # counter in the original record is incremented after it has been used to modify the title
          original_post.counter += 1
          # Ensure that the counter is updated in the database
          original_post.save
        }
      ]
    )

    override(lambda { |original_post, new_post|
      # `(counter)` will be added before '???' is appended to the contents
      new_post.contents += " (#{original_post.counter})"
    })
  end
end
```

#### Example

```ruby
irb* original = Post.create(
irb*   title: 'Lorem ipsum dolor sit amet.',
irb*   contents: 'Nulla pharetra porta metus id porttitor.',
irb*   counter: 5
irb> )
irb> original.title
=> "Lorem ipsum dolor sit amet."
irb> original.contents
=> "Nulla pharetra porta metus id porttitor."
irb> original.counter
=> 5
irb> copy = original.amoeba_dup
irb> copy.title
=> "Lorem ipsum dolor sit amet. <<< (5)"
irb> copy.contents
=> "Nulla pharetra porta metus id porttitor. (5) ???"
irb> copy.counter
=> 5
irb> original.counter
=> 6
```
