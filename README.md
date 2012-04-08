# Amoeba

Easy copying of rails associations such as `has_many`.

![amoebalogo](http://rocksolidwebdesign.com/wp_cms/wp-content/uploads/2012/02/amoeba_logo.jpg)

## What?

The goal was to be able to easily and quickly reproduce ActiveRecord objects including their children, for example copying a blog post maintaining its associated tags or categories.

This gem is named "Amoeba" because amoebas are (small life forms that are) good at reproducing. Their children and grandchildren also reproduce themselves quickly and easily.

### Technical Details

An ActiveRecord extension gem to allow the duplication of associated child record objects when duplicating an active record model. This gem overrides and adds to the built in `ActiveRecord::Base#dup` method.

Rails 3.2 compatible.

### Features

- Supports the following association types
    - `has_many`
    - `has_one :through`
    - `has_many :through`
    - `has_and_belongs_to_many`
- A simple DSL for configuration of which fields to copy. The DSL can be applied to your rails models or used on the fly.
- Supports STI (Single Table Inheritance) children inheriting their parent amoeba settings.
- Multiple configuration styles such as inclusive, exclusive and indiscriminate (aka copy everything).
- Supports cloning of the children of Many-to-Many records or merely maintaining original associations
- Supports automatic drill-down i.e. recursive copying of child and grandchild records.
- Supports preprocessing of fields to help indicate uniqueness and ensure the integrity of your data depending on your business logic needs, e.g. prepending "Copy of " or similar text.
- Supports preprocessing of fields with custom lambda blocks so you can do basically whatever you want if, for example, you need some custom logic while making copies.
- Amoeba can perform the following preprocessing operations on fields of copied records
    - set
    - prepend
    - append
    - nullify
    - customize
    - regex

## Usage

### Installation

is hopefully as you would expect:

    gem install amoeba

or just add it to your Gemfile:

    gem 'amoeba'

Configure your models with one of the styles below and then just run the `dup` method on your model as you normally would:

    p = Post.create(:title => "Hello World!", :content => "Lorum ipsum dolor")
    p.comments.create(:content => "I love it!")
    p.comments.create(:content => "This sucks!")

    puts Comment.all.count # should be 2

    my_copy = p.dup
    my_copy.save

    puts Comment.all.count # should be 4

By default, when enabled, amoeba will copy any and all associated child records automatically and associated them with the new parent record.

You can configure the behavior to only include fields that you list or to only include fields that you don't exclude. Of the three, the most performant will be the indiscriminate style, followed by the inclusive style, and the exclusive style will be the slowest because of the need for an extra explicit check on each field. This performance difference is likely negligible enough that you can choose the style to use based on which is easiest to read and write, however, if your data tree is large enough and you need control over what fields get copied, inclusive style is probably a better choice than exclusive style.

### Configuration

Please note that these examples are only loose approximations of real world scenarios and may not be particularly realistic, they are only for the purpose of demonstrating feature usage.

#### Indiscriminate Style

This is the most basic usage case and will simply enable the copying of any known associations.

If you have some models for a blog about like this:

    class Post < ActiveRecord::Base
      has_many :comments
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

simply add the amoeba configuration block to your model and call the enable method to enable the copying of child records, like this:

    class Post < ActiveRecord::Base
      has_many :comments

      amoeba do
        enable
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

Child records will be automatically copied when you run the dup method.

#### Inclusive Style

If you only want some of the associations copied but not others, you may use the inclusive style:

    class Post < ActiveRecord::Base
      has_many :comments
      has_many :tags
      has_many :authors

      amoeba do
        enable
        include_field :tags
        include_field :authors
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

Using the inclusive style within the amoeba block actually implies that you wish to enable amoeba, so there is no need to run the enable method, though it won't hurt either:

    class Post < ActiveRecord::Base
      has_many :comments
      has_many :tags
      has_many :authors

      amoeba do
        include_field :tags
        include_field :authors
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

You may also specify fields to be copied by passing an array. If you call the `include_field` with a single value, it will be appended to the list of already included fields. If you pass an array, your array will overwrite the original values.

    class Post < ActiveRecord::Base
      has_many :comments
      has_many :tags
      has_many :authors

      amoeba do
        include_field [:tags, :authors]
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

These examples will copy the post's tags and authors but not its comments.

The inclusive style, when used, will automatically disable any ther style that was previously selected.

#### Exclusive Style

If you have more fields to include than to exclude, you may wish to shorten the amount of typing and reading you need to do by using the exclusive style. All fields that are not explicitly excluded will be copied:

    class Post < ActiveRecord::Base
      has_many :comments
      has_many :tags
      has_many :authors

      amoeba do
        exclude_field :comments
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

This example does the same thing as the inclusive style example, it will copy the post's tags and authors but not its comments. As with inclusive style, there is no need to explicitly enable amoeba when specifying fields to exclude.

The exclusive style, when used, will automatically disable any other style that was previously selected, so if you selected include fields, and then you choose some exclude fields, the `exclude_field` method will disable the previously slected inclusive style and wipe out any corresponding include fields.

#### Cloning

If you are using a Many-to-Many relationship, you may tell amoeba to actually make duplicates of the original related records rather than merely maintaining association with the original records. Cloning is easy, merely tell amoeba which fields to clone in the same way you tell it which fields to include or exclude.

    class Post < ActiveRecord::Base
      has_and_belongs_to_many :warnings

      has_many :post_widgets
      has_many :widgets, :through => :post_widgets

      amoeba do
        enable
        clone [:widgets, :tags]
      end
    end

    class Warning < ActiveRecord::Base
      has_and_belongs_to_many :posts
    end

    class PostWidget < ActiveRecord::Base
      belongs_to :widget
      belongs_to :post
    end

    class Widget < ActiveRecord::Base
      has_many :post_widgets
      has_many :posts, :through => :post_widgets
    end

This example will actually duplicate the warnings and widgets in the database. If there were originally 3 warnings in the database then, upon duplicating a post, you will end up with 6 warnings in the database. This is in contrast to the default behavior where your new post would merely be re-associated with any previously existing warnings and those warnings themselves would not be duplicated.

### Limiting Association Types

By default, amoeba recognizes and attemps to copy any children of the following association types:

 - has one
 - has many
 - has and belongs to many

You may control which association types amoeba applies itself to by using the `recognize` method within the amoeba configuration block.

    class Post < ActiveRecord::Base
      has_one :config
      has_many :comments
      has_and_belongs_to_many :tags

      amoeba do
        recognize [:has_one, :has_and_belongs_to_many]
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

    class Tag < ActiveRecord::Base
      has_and_belongs_to_many :posts
    end

This example will copy the post's configuration data and keep tags associated with the new post, but will not copy the post's comments because amoeba will only recognize and copy children of `has_one` and `has_and_belongs_to_many` associations and in this example, comments are not an `has_and_belongs_to_many` association.

### Nested Association Validation

If you end up with some validation issues when trying to validate the presence of a child's `belongs_to` association, just be sure to include the `:inverse_of` declaration on your relationships and all should be well.

For example this will throw a validation error saying that your posts are invalid:

    class Author < ActiveRecord::Base
      has_many :posts

      amoeba do
        enable
      end
    end

    class Post < ActiveRecord::Base
      belongs_to :author
      validates_presence_of :author

      amoeba do
        enable
      end
    end

    author = Author.find(1)
    author.dup

    author.save # this will fail validation

Wheras this will work fine:

    class Author < ActiveRecord::Base
      has_many :posts, :inverse_of => :author

      amoeba do
        enable
      end
    end

    class Post < ActiveRecord::Base
      belongs_to :author, :inverse_of => :posts
      validates_presence_of :author

      amoeba do
        enable
      end
    end

    author = Author.find(1)
    author.dup

    author.save # this will pass validation

This issue is not amoeba specific and also occurs when creating new objects using `accepts_nested_attributes_for`, like this:

    class Author < ActiveRecord::Base
      has_many :posts
      accepts_nested_attributes_for :posts
    end

    class Post < ActiveRecord::Base
      belongs_to :author
      validates_presence_of :author
    end

    # this will fail validation
    author = Author.create({:name => "Jim Smith", :posts => [{:title => "Hello World", :contents => "Lorum ipsum dolor}]})

This issue with `accepts_nested_attributes_for` can also be solved by using `:inverse_of`, like this:

    class Author < ActiveRecord::Base
      has_many :posts, :inverse_of => :author
      accepts_nested_attributes_for :posts
    end

    class Post < ActiveRecord::Base
      belongs_to :author, :inverse_of => :posts
      validates_presence_of :author
    end

    # this will pass validation
    author = Author.create({:name => "Jim Smith", :posts => [{:title => "Hello World", :contents => "Lorum ipsum dolor}]})

The crux of the issue is that upon duplication, the new `Author` instance does not yet have an ID because it has not yet been persisted, so the `:posts` do not yet have an `:author_id` either, and thus no `:author` and thus they will fail validation. This issue may likely affect amoeba usage so if you get some validation failures, be sure to add `:inverse_of` to your models.

### Field Preprocessors

#### Nullify

If you wish to prevent a regular (non `has_*` association based) field from retaining it's value when copied, you may "zero out" or "nullify" the field, like this:

    class Topic < ActiveRecord::Base
      has_many :posts
    end

    class Post < ActiveRecord::Base
      belongs_to :topic
      has_many :comments

      amoeba do
        enable
        nullify :date_published
        nullify :topic_id
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

This example will copy all of a post's comments. It will also nullify the publishing date and dissociate the post from its original topic.

Unlike inclusive and exclusive styles, specifying null fields will not automatically enable amoeba to copy all child records. As with any active record object, the default field value will be used instead of `nil` if a default value exists on the migration.

#### Set

If you wish to just set a field to an aribrary value on all duplicated objects you may use the `set` directive. For example, if you wanted to copy an object that has some kind of approval process associated with it, you likely may wish to set the new object's state to be open or "in progress" again.

    class Post < ActiveRecord::Base
      amoeba do
        set :state_tracker => "open_for_editing"
      end
    end

In this example, when a post is duplicated, it's `state_tracker` field will always be given a value of `open_for_editing` to start.

#### Prepend

You may add a string to the beginning of a copied object's field during the copy phase:

    class Post < ActiveRecord::Base
      amoeba do
        enable
        prepend :title => "Copy of "
      end
    end

#### Append

You may add a string to the end of a copied object's field during the copy phase:

    class Post < ActiveRecord::Base
      amoeba do
        enable
        append :title => "Copy of "
      end
    end

#### Regex

You may run a search and replace query on a copied object's field during the copy phase:

    class Post < ActiveRecord::Base
      amoeba do
        enable
        regex :contents => {:replace => /dog/, :with => 'cat'}
      end
    end

#### Custom Methods

##### Customize

You may run a custom method or methods to do basically anything you like, simply pass a lambda block, or an array of lambda blocks to the `customize` directive. Each block must have the same form, meaning that each block must accept two parameters, the original object and the newly copied object. You may then do whatever you wish, like this:

    class Post < ActiveRecord::Base
      amoeba do
        prepend :title => "Hello world! "

        customize(lambda { |original_post,new_post|
          if original_post.foo == "bar"
            new_post.baz = "qux"
          end
        })

        append :comments => "... know what I'm sayin?"
      end
    end

or this, using an array:

    class Post < ActiveRecord::Base
      has_and_belongs_to_many :tags

      amoeba do
        include_field :tags

        customize([
          lambda do |orig_obj,copy_of_obj|
            # good stuff goes here
          end,

          lambda do |orig_obj,copy_of_obj|
            # more good stuff goes here
          end
        ])
      end
    end

##### Override

Lambda blocks passed to customize run, by default, after all copying and field pre-processing. If you wish to run a method before any customization or field pre-processing, you may use `override` the cousin of `customize`. Usage is the same as above.

    class Post < ActiveRecord::Base
      amoeba do
        prepend :title => "Hello world! "

        override(lambda { |original_post,new_post|
          if original_post.foo == "bar"
            new_post.baz = "qux"
          end
        })

        append :comments => "... know what I'm sayin?"
      end
    end

#### Chaining

You may apply a single preprocessor to multiple fields at once.

    class Post < ActiveRecord::Base
      amoeba do
        enable
        prepend :title => "Copy of ", :contents => "Copied contents: "
      end
    end

#### Stacking

You may apply multiple preproccessing directives to a single model at once.

    class Post < ActiveRecord::Base
      amoeba do
        prepend :title => "Copy of ", :contents => "Original contents: "
        append :contents => " (copied version)"
        regex :contents => {:replace => /dog/, :with => 'cat'}
      end
    end

This example should result in something like this:

    post = Post.create(
      :title => "Hello world",
      :contents =>  "I like dogs, dogs are awesome."
    )

    new_post = post.dup

    new_post.title # "Copy of Hello world"
    new_post.contents # "Original contents: I like cats, cats are awesome. (copied version)"

Like `nullify`, the preprocessing directives do not automatically enable the copying of associated child records. If only preprocessing directives are used and you do want to copy child records and no `include_field` or `exclude_field` list is provided, you must still explicitly enable the copying of child records by calling the enable method from within the amoeba block on your model.

### Precedence

You may use a combination of configuration methods within each model's amoeba block. Recognized association types take precedence over inclusion or exclusion lists. Inclusive style takes precedence over exclusive style, and these two explicit styles take precedence over the indiscriminate style. In other words, if you list fields to copy, amoeba will only copy the fields you list, or only copy the fields you don't exclude as the case may be. Additionally, if a field type is not recognized it will not be copied, regardless of whether it appears in an inclusion list. If you want amoeba to automatically copy all of your child records, do not list any fields using either `include_field` or `exclude_field`.

The following example syntax is perfectly valid, and will result in the usage of inclusive style. The order in which you call the configuration methods within the amoeba block does not matter:

    class Topic < ActiveRecord::Base
      has_many :posts
    end

    class Post < ActiveRecord::Base
      belongs_to :topic
      has_many :comments
      has_many :tags
      has_many :authors

      amoeba do
        exclude_field :authors
        include_field :tags
        nullify :date_published
        prepend :title => "Copy of "
        append :contents => " (copied version)"
        regex :contents => {:replace => /dog/, :with => 'cat'}
        include_field :authors
        enable
        nullify :topic_id
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

This example will copy all of a post's tags and authors, but not its comments. It will also nullify the publishing date and dissociate the post from its original topic. It will also preprocess the post's fields as in the previous preprocessing example.

Note that, because of precedence, inclusive style is used and the list of exclude fields is never consulted. Additionally, the `enable` method is redundant because amoeba is automatically enabled when using `include_field`.

The preprocessing directives are run after child records are copied andare run in this order.

 1. Null fields
 2. Prepends
 3. Appends
 4. Search and Replace

Preprocessing directives do not affect inclusion and exclusion lists.

### Recursing

You may cause amoeba to keep copying down the chain as far as you like, simply add amoeba blocks to each model you wish to have copy its children. Amoeba will automatically recurse into any enabled grandchildren and copy them as well.

    class Post < ActiveRecord::Base
      has_many :comments

      amoeba do
        enable
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
      has_many :ratings

      amoeba do
        enable
      end
    end

    class Rating < ActiveRecord::Base
      belongs_to :comment
    end

In this example, when a post is copied, amoeba will copy each all of a post's comments and will also copy each comment's ratings.

### Has One Through

Using the `has_one :through` association is simple, just be sure to enable amoeba on the each model with a `has_one` association and amoeba will automatically and recursively drill down, like so:

    class Supplier < ActiveRecord::Base
      has_one :account
      has_one :history, :through => :account

      amoeba do
        enable
      end
    end

    class Account < ActiveRecord::Base
      belongs_to :supplier
      has_one :history

      amoeba do
        enable
      end
    end

    class History < ActiveRecord::Base
      belongs_to :account
    end

### Has Many Through

Copying of `has_many :through` associations works automatically. They perform the copy in the same way as the `has_and_belongs_to_many` association, meaning the actual child records are not copied, but rather the associations are simply maintained. You can add some field preprocessors to the middle model if you like but this is not strictly necessary:

    class Assembly < ActiveRecord::Base
      has_many :manifests
      has_many :parts, :through => :manifests

      amoeba do
        enable
      end
    end

    class Manifest < ActiveRecord::Base
      belongs_to :assembly
      belongs_to :part

      amoeba do
        prefix :notes => "Copy of "
      end
    end

    class Part < ActiveRecord::Base
      has_many :manifests
      has_many :assemblies, :through => :manifests

      amoeba do
        enable
      end
    end

### On The Fly Configuration

You may control how amoeba copies your object, on the fly, by passing a configuration block to the model's amoeba method. The configuration method is static but the configuration is applied on a per instance basis.

    class Post < ActiveRecord::Base
      has_many :comments

      amoeba do
        enable
        prepend :title => "Copy of "
      end
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end

    class PostsController < ActionController
      def duplicate_a_post
        old_post = Post.create(
          :title => "Hello world",
          :contents => "Lorum ipsum"
        )

        old_post.class.amoeba do
          prepend :contents => "Here's a copy: "
        end

        new_post = old_post.dup

        new_post.title # should be "Copy of Hello world"
        new_post.contents # should be "Here's a copy: Lorum ipsum"
        new_post.save
      end
    end

### Inheritance

If you are using the Single Table Inheritance provided by ActiveRecord, you may cause amoeba to automatically process child classes in the same way as their parents. All you need to do is call the `propagate` method within the amoeba block of the parent class and all child classes should copy in a similar manner.

    create_table :products, :force => true do |t|
      t.string :type # this is the STI column

      # these belong to all products
      t.string :title
      t.decimal :price

      # these are for shirts only
      t.decimal :sleeve_length
      t.decimal :collar_size

      # these are for computers only
      t.integer :ram_size
      t.integer :hard_drive_size
    end

    class Product < ActiveRecord::Base
      has_many :images
      has_and_belongs_to_many :categories

      amoeba do
        enable
        propagate
      end
    end

    class Shirt < Product
    end

    class Computer < Product
    end

    class ProductsController
      def some_method
        my_shirt = Shirt.find(1)
        my_shirt.dup
        my_shirt.save

        # this shirt should now:
        # - have its own copy of all parent images
        # - be in the same categories as the parent
      end
    end

This example should duplicate all the images and sections associated with this Shirt, which is a child of Product

#### Parenting Style

By default, propagation uses submissive parenting, meaning the config settings on the parent will be applied, but any child settings, if present, will either add to or overwrite the parent settings depending on how you call the DSL methods.

You may change this behavior, the so called "parenting style", to give preference to the parent settings or to ignore any and all child settings.

##### Relaxed Parenting

The `:relaxed` parenting style will prefer parent settings.

    class Product < ActiveRecord::Base
      has_many :images
      has_and_belongs_to_many :sections

      amoeba do
        exclude_field :images
        propagate :relaxed
      end
    end

    class Shirt < Product
      include_field :images
      include_field :sections
      prepend :title => "Copy of "
    end

In this example, the conflicting `include_field` settings on the child will be ignored and the parent `exclude_field` setting will be used, while the `prepend` setting on the child will be honored because it doesn't conflict with the parent.

##### Strict Parenting

The `:strict` style will ignore child settings altogether and inherit any parent settings.

    class Product < ActiveRecord::Base
      has_many :images
      has_and_belongs_to_many :sections

      amoeba do
        exclude_field :images
        propagate :strict
      end
    end

    class Shirt < Product
      include_field :images
      include_field :sections
      prepend :title => "Copy of "
    end

In this example, the only processing that will happen when a Shirt is duplicated is whatever processing is allowed by the parent. So in this case the parent's `exclude_field` directive takes precedence over the child's `include_field` settings, and not only that, but none of the other settings for the child are used either. The `prepend` setting of the child is completely ignored.

##### Parenting and Precedence

Because of the two general forms of DSL config parameter usage, you may wish to make yourself mindful of how your coding style will affect the outcome of duplicating an object.

Just remember that:

* If you pass an array you will wipe all previous settings
* If you pass single values, you will add to currently existing settings

This means that, for example:

* When using the submissive parenting style, you can child take full precedence on a per field basis by passing an array of config values. This will cause the setting from the parent to be overridden instead of added to.
* When using the relaxed parenting style, you can still let the parent take precedence on a per field basis by passing an array of config values. This will cause the setting for that child to be overridden instead of added to.

##### A Submissive Override Example

This version will use both the parent and child settings, so both the images and sections will be copied.

    class Product < ActiveRecord::Base
      has_many :images
      has_and_belongs_to_many :sections

      amoeba do
        include_field :images
        propagate
      end
    end

    class Shirt < Product
      include_field :sections
    end

The next version will use only the child settings because passing an array will override any previous settings rather than adding to them and the child config takes precedence in the `submissive` parenting style. So in this case only the sections will be copied.

    class Product < ActiveRecord::Base
      has_many :images
      has_and_belongs_to_many :sections

      amoeba do
        include_field :images
        propagate
      end
    end

    class Shirt < Product
      include_field [:sections]
    end

##### A Relaxed Override Example

This version will use both the parent and child settings, so both the images and sections will be copied.

    class Product < ActiveRecord::Base
      has_many :images
      has_and_belongs_to_many :sections

      amoeba do
        include_field :images
        propagate :relaxed
      end
    end

    class Shirt < Product
      include_field :sections
    end

The next version will use only the parent settings because passing an array will override any previous settings rather than adding to them and the parent config takes precedence in the `relaxed` parenting style. So in this case only the images will be copied.

    class Product < ActiveRecord::Base
      has_many :images
      has_and_belongs_to_many :sections

      amoeba do
        include_field [:images]
        propagate
      end
    end

    class Shirt < Product
      include_field :sections
    end

## Configuration Reference

Here is a static reference to the available configuration methods, usable within the amoeba block on your rails models.

### Controlling Associations

#### enable

  Enables amoeba in the default style of copying all known associated child records. Using the enable method is only required if you wish to enable amoeba but you are not using either the `include_field` or `exclude_field` directives. If you use either inclusive or exclusive style, amoeba is automatically enabled for you, so calling `enable` would be redundant, though it won't hurt.

#### include_field

  Adds a field to the list of fields which should be copied. All associations not in this list will not be copied. This method may be called multiple times, once per desired field, or you may pass an array of field names. Passing a single symbol will add to the list of included fields. Passing an array will empty the list and replace it with the array you pass.

#### exclude_field

  Adds a field to the list of fields which should not be copied. Only the associations that are not in this list will be copied. This method may be called multiple times, once per desired field, or you may pass an array of field names. Passing a single symbol will add to the list of excluded fields. Passing an array will empty the list and replace it with the array you pass.

#### clone

  Adds a field to the list of associations which should have their associated children actually cloned. This means for example, that instead of just maintaining original associations with previously existing tags, a copy will be made of each tag, and the new record will be associated with these new tag copies rather than the old tag copies. This method may be called multiple times, once per desired field, or you may pass an array of field names. Passing a single symbol will add to the list of excluded fields. Passing an array will empty the list and replace it with the array you pass.

#### propagate

  This causes any inherited child models to take the same config settings when copied. This method may take up to one argument to control the so called "parenting style". The argument should be one of `strict`, `relaxed` or `submissive`.

  The default "parenting style" is `submissive`

  for example

        amoeba do
          propagate :strict
        end

  will choose the strict parenting style of inherited settings.

#### raised

  This causes any child to behave with a (potentially) different "parenting style" than its actual parent. This method takes up to a single parameter for which there are three options, `strict`, `relaxed` and `submissive`.

  The default "parenting style" is `submissive`

  for example:

        amoeba do
          raised :relaxed
        end

  will choose the relaxed parenting style of inherited settings for this child. A parenting style set via the `raised` method takes precedence over the parenting style set using the `propagate` method.

### Pre-Processing Fields

#### nullify

  Adds a field to the list of non-association based fields which should be set to nil during copy. All fields in this list will be set to `nil` - note that any nullified field will be given its default value if a default value exists on this model's migration. This method may be called multiple times, once per desired field, or you may pass an array of field names. Passing a single symbol will add to the list of null fields. Passing an array will empty the list and replace it with the array you pass.

#### prepend

  Prefix a field with some text. This only works for string fields. Accepts a hash of fields to prepend. The keys are the field names and the values are the prefix strings. An example scenario would be to add a string such as "Copy of " to your title field. Don't forget to include extra space to the right if you want it. Passing a hash will add each key value pair to the list of prepend directives. If you wish to empty the list of directives, you may pass the hash inside of an array like this `[{:title => "Copy of "}]`.

#### append

  Append some text to a field. This only works for string fields. Accepts a hash of fields to prepend. The keys are the field names and the values are the prefix strings. An example would be to add " (copied version)" to your description field. Don't forget to add a leading space if you want it. Passing a hash will add each key value pair to the list of append directives. If you wish to empty the list of directives, you may pass the hash inside of an array like this `[{:contents => " (copied version)"}]`.

#### set

  Set a field to a given value. This sould work for almost any type of field. Accepts a hash of fields and the values you want them set to.. The keys are the field names and the values are the prefix strings. An example would be to add " (copied version)" to your description field. Don't forget to add a leading space if you want it. Passing a hash will add each key value pair to the list of append directives. If you wish to empty the list of directives, you may pass the hash inside of an array like this `[{:approval_state => "open_for_editing"}]`.

#### regex

  Globally search and replace the field for a given pattern. Accepts a hash of fields to run search and replace upon. The keys are the field names and the values are each a hash with information about what to find and what to replace it with. in the form of . An example would be to replace all occurrences of the word "dog" with the word "cat", the parameter hash would look like this `:contents => {:replace => /dog/, :with => "cat"}`. Passing a hash will add each key value pair to the list of regex directives. If you wish to empty the list of directives, you may pass the hash inside of an array like this `[{:contents => {:replace => /dog/, :with => "cat"}]`.

#### customize

  Runs a custom method so you can do basically whatever you want. All you need to do is pass a lambda block or an array of lambda blocks that take two parameters, the original object and the new object copy

  This method may be called multiple times, once per desired customizer block, or you may pass an array of lambdas. Passing a single lambda will add to the list of processing directives. Passing an array will empty the list and replace it with the array you pass.

## Known Limitations and Issues

The regular expression preprocessor uses case-sensitive `String#gsub`. Given the performance decreases inherrent in using regular expressions already, the fact that character classes can essentially account for case-insensitive searches, the desire to keep the DSL simple and the general use cases for this gem, I don't see a good reason to add yet more decision based conditional syntax to accommodate using case-insensitive searches or singular replacements with `String#sub`. If you find yourself wanting either of these features, by all means fork the code base and if you like your changes, submit a pull request.

The behavior when copying nested hierarchical models is undefined. Copying a category model which has a `parent_id` field pointing to the parent category, for example, is currently undefined.

The behavior when copying polymorphic `has_many` associations is also undefined. Support for these types of associations is planned for a future release.

## For Developers

You may run the rspec tests like this:

    bundle exec rspec spec

### TODO

* add ability to cancel further processing from within an override block
* write some spec for the override method

## License

[The BSD License](http://www.opensource.org/licenses/bsd-license.php)

Copyright (c) 2012, Vaughn Draughon
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
