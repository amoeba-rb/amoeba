class Topic < ActiveRecord::Base
  has_many :posts
end

class User < ActiveRecord::Base
  has_many :posts
end

class Author < ActiveRecord::Base
  has_many :posts, :inverse_of => :author
  amoeba do
    enable
  end
end

class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :owner, :class_name => 'User'
  belongs_to :author, :inverse_of => :posts
  has_one :post_config
  has_one :account
  has_one :history, :through => :account
  has_many :comments
  has_many :supercats
  has_many :categories, :through => :supercats
  has_many :post_widgets
  has_many :widgets, :through => :post_widgets
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :notes

  validates_presence_of :topic
  validates_presence_of :author

  amoeba do
    enable
    clone [:widgets, :notes]
    prepend :title => "Copy of "
    append :contents => " (copied version)"
    regex :contents => {:replace => /dog/, :with => 'cat'}
    customize([
      lambda do |orig_obj,copy_of_obj|
        orig_obj.comments.each do |oc|
          if oc.nerf == "ratatat"
            hash = oc.attributes
            hash[:id]       = nil
            hash[:post_id]  = nil
            hash[:contents] = nil

            cc = Comment.new(hash)

            copy_of_obj.comments << cc
          end
        end
      end,
      lambda do |orig_obj,copy_of_obj|
        orig_obj.comments.each do |oc|
          if oc.nerf == "bonk"
            hash = oc.attributes
            hash[:id]       = nil
            hash[:post_id]  = nil
            hash[:contents] = nil
            hash[:nerf]     = "bonkers"

            cc = Comment.new(hash)

            copy_of_obj.comments << cc
          end
        end
      end
    ])
  end
end

class CustomThing < ActiveRecord::Base
  belongs_to :post
end

class Account < ActiveRecord::Base
  belongs_to :post
  has_one :history

  amoeba do
    enable
  end
end

class History < ActiveRecord::Base
  belongs_to :account
end

class Category < ActiveRecord::Base
  has_many :supercats
  has_many :posts, :through => :supercats

  amoeba do
    enable
    prepend :ramblings => "Copy of "
    set :other_ramblings => "La la la"
  end
end

class Supercat < ActiveRecord::Base
  belongs_to :post
  belongs_to :category
  has_many :superkittens

  amoeba do
    include_field :superkittens
    prepend :ramblings => "Copy of "
    set :other_ramblings => "La la la"
  end
end

class Superkitten < ActiveRecord::Base
  belongs_to :supercat
end

class PostConfig < ActiveRecord::Base
  belongs_to :post
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_many :ratings
  has_many :reviews

  amoeba do
    exclude_field :reviews
  end
end

class Review < ActiveRecord::Base
  belongs_to :comment
end

class Rating < ActiveRecord::Base
  belongs_to :comment
end

class Widget < ActiveRecord::Base
  has_many :post_widgets
  has_many :posts, :through => :post_widgets
end

class PostWidget < ActiveRecord::Base
  belongs_to :post
  belongs_to :widget
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
end

class Note < ActiveRecord::Base
  has_and_belongs_to_many :posts
end

# Inheritance
class Product < ActiveRecord::Base
  has_many :images
  has_and_belongs_to_many :sections

  amoeba do
    enable
    propagate
  end
end

class Section < ActiveRecord::Base
end

class Image < ActiveRecord::Base
end

class Shirt < Product
  amoeba do
    raised :submissive
  end
end

class Necklace < Product
  amoeba do
    raised :relaxed
  end
end

# Polymorphism
class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true
end

class Employee < ActiveRecord::Base
  has_many :addresses, :as => :addressable
end

class Customer < ActiveRecord::Base
  has_many :addresses, :as => :addressable
end

