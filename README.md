# Amoeba

Easy copying of rails associations such as `has_many`.

![amoebalogo](http://rocksolidwebdesign.com/wp_cms/wp-content/uploads/2012/02/amoeba_logo.jpg)

## Background

The goal was to be able to easily and quickly reproduce ActiveRecord objects including their children, for example copying a blog post maintaining its associated tags or categories.

I named this gem "Amoeba" because amoebas are (small life forms that are) good at reproducing. Their children and grandchildren also reproduce themselves quickly and easily.

## Details

An ActiveRecord extension gem to allow the duplication of associated child record objects when duplicating an active record model. This gem overrides and adds to the built in `ActiveRecord::Base#dup` method.

Rails 3.2 compatible.

## Features

- Supports the following association types
    - `has_many`
    - `has_one :through`
    - `has_many :through`
    - `has_and_belongs_to_many`
- A simple DSL for configuration of which fields to copy. The DSL can be applied to your rails models or used on the fly.
- Multiple configuration styles such as inclusive, exclusive and indiscriminate (aka copy everything).
- Supports cloning of the children of Many-to-Many records as well as not cloning the child records but merely maintaining original associations
- Supports recursive copying of child and grandchild records.
- Supports preprocessing of fields to help indicate uniqueness and ensure the integrity of your data depending on your business logic needs, e.g. prepending "Copy of " or similar text.
- Amoeba can perform the following preprocessing operations on fields of copied records
    - set
    - prepend
    - append
    - nullify
    - regex

## Installation

is hopefully as you would expect:

    gem install amoeba

or just add it to your Gemfile:

    gem 'amoeba'

## Usage

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

## Configuration

Please note that these examples are only loose approximations of real world scenarios and may not be particularly realistic, they are only for the purpose of demonstrating feature usage.

### Indiscriminate Style

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

### Inclusive Style

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

### Exclusive Style

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

### Cloning

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

#### Chaining

You may apply a preprocessor to multiple fields at once.

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

### Config-Block Reference

Here is a static reference to the available configuration methods, usable within the amoeba block on your rails models.

`enable`

Enables amoeba in the default style of copying all known associated child records. Using the enable method is only required if you wish to enable amoeba but you are not using either the `include_field` or `exclude_field` directives. If you use either inclusive or exclusive style, amoeba is automatically enabled for you, so calling `enable` would be redundant, though it won't hurt.

`include_field`

Adds a field to the list of fields which should be copied. All associations not in this list will not be copied. This method may be called multiple times, once per desired field, or you may pass an array of field names. Passing a single symbol will add to the list of included fields. Passing an array will empty the list and replace it with the array you pass.

`exclude_field`

Adds a field to the list of fields which should not be copied. Only the associations that are not in this list will be copied. This method may be called multiple times, once per desired field, or you may pass an array of field names. Passing a single symbol will add to the list of excluded fields. Passing an array will empty the list and replace it with the array you pass.

`nullify`

Adds a field to the list of non-association based fields which should be set to nil during copy. All fields in this list will be set to `nil` - note that any nullified field will be given its default value if a default value exists on this model's migration. This method may be called multiple times, once per desired field, or you may pass an array of field names. Passing a single symbol will add to the list of null fields. Passing an array will empty the list and replace it with the array you pass.

`prepend`

Prefix a field with some text. This only works for string fields. Accepts a hash of fields to prepend. The keys are the field names and the values are the prefix strings. An example scenario would be to add a string such as "Copy of " to your title field. Don't forget to include extra space to the right if you want it. Passing a hash will add each key value pair to the list of prepend directives. If you wish to empty the list of directives, you may pass the hash inside of an array like this `[{:title => "Copy of "}]`.

`append`

Append some text to a field. This only works for string fields. Accepts a hash of fields to prepend. The keys are the field names and the values are the prefix strings. An example would be to add " (copied version)" to your description field. Don't forget to add a leading space if you want it. Passing a hash will add each key value pair to the list of append directives. If you wish to empty the list of directives, you may pass the hash inside of an array like this `[{:contents => " (copied version)"}]`.

`regex`

Globally search and replace the field for a given pattern. Accepts a hash of fields to run search and replace upon. The keys are the field names and the values are each a hash with information about what to find and what to replace it with. in the form of . An example would be to replace all occurrences of the word "dog" with the word "cat", the parameter hash would look like this `:contents => {:replace => /dog/, :with => "cat"}`. Passing a hash will add each key value pair to the list of regex directives. If you wish to empty the list of directives, you may pass the hash inside of an array like this `[{:contents => {:replace => /dog/, :with => "cat"}]`.

## Known Limitations and Issues

Amoeba does not copy the actual HABMT child records but rather simply adds records to the M:M breakout table to associate the new parent copy with the same records that the original parent were associated with. In other words, it doesn't duplicate your tags or categories, but merely reassociates your parent copy with the same tags or categories that the old parent had.

The regular expression preprocessor uses case-sensitive `String#gsub`. Given the performance decreases inherrent in using regular expressions already, the fact that character classes can essentially account for case-insensitive searches, the desire to keep the DSL simple and the general use cases for this gem, I don't see a good reason to add yet more decision based conditional syntax to accommodate using case-insensitive searches or singular replacements with `String#sub`. If you find yourself wanting either of these features, by all means fork the code base and if you like your changes, submit a pull request.

The behavior when copying nested hierarchical models is undefined. Copying a category model which has a `parent_id` field pointing to the parent category, for example, is currently undefined. The behavior when copying polymorphic `has_many` associations is also undefined. Support for these types of associations is planned for a future release.

### For Developers

You may run the rspec tests like this:

    bundle exec rspec spec

## TODO

Write more tests.... anyone?

## License

[The BSD License](http://www.opensource.org/licenses/bsd-license.php)

Copyright (c) 2012, Vaughn Draughon
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
