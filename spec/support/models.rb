class Topic < ActiveRecord::Base
  has_many :posts
end

class User < ActiveRecord::Base
  has_many :posts
end

class Author < ActiveRecord::Base
  has_many :posts, inverse_of: :author
  amoeba do
    enable
  end
end

class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :owner, class_name: 'User'
  belongs_to :author, inverse_of: :posts
  has_one :post_config
  has_one :account
  has_one :history, through: :account
  has_many :comments
  has_many :supercats
  has_many :categories, through: :supercats
  has_many :post_widgets
  has_many :widgets, through: :post_widgets
  has_many :custom_things
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :notes

  validates_presence_of :topic
  validates_presence_of :author

  amoeba do
    enable
    clone [:widgets, :notes]
    prepend title: 'Copy of '
    append contents: ' (copied version)'
    regex contents: { replace: /dog/, with: 'cat' }
    customize([
      lambda do |orig_obj, copy_of_obj|
        orig_obj.comments.each do |oc|
          if oc.nerf == 'ratatat'
            hash = oc.attributes
            hash[:id]       = nil
            hash[:post_id]  = nil
            hash[:contents] = nil

            cc = Comment.new(hash)

            copy_of_obj.comments << cc
          end
        end
      end,
      lambda do |orig_obj, copy_of_obj|
        orig_obj.comments.each do |oc|
          if oc.nerf == 'bonk'
            hash = oc.attributes
            hash[:id]       = nil
            hash[:post_id]  = nil
            hash[:contents] = nil
            hash[:nerf]     = 'bonkers'

            cc = Comment.new(hash)

            copy_of_obj.comments << cc
          end
        end
      end
    ])
  end

  def truthy?
    true
  end

  def falsey?
    false
  end

  class << self
    def tag_count
      ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS tag_count FROM posts_tags')['tag_count']
    end

    def note_count
      ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS note_count FROM notes_posts')['note_count']
    end
  end
end

class CustomThing < ActiveRecord::Base
  belongs_to :post

  class ArrayPack
    def self.load(str)
      return [] unless str.present?
      return str if str.is_a?(Array)
      str.split(',').map(&:to_i)
    end

    def self.dump(int_array)
      return '' unless int_array.present?
      int_array.join(',')
    end
  end

  serialize :value, ArrayPack

  before_create :hydrate_me

  def hydrate_me
    self.value = value
  end
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
  has_many :posts, through: :supercats

  amoeba do
    enable
    prepend ramblings: 'Copy of '
    set other_ramblings: 'La la la'
  end
end

class Supercat < ActiveRecord::Base
  belongs_to :post
  belongs_to :category
  has_many :superkittens

  amoeba do
    include_association :superkittens
    prepend ramblings: 'Copy of '
    set other_ramblings: 'La la la'
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
    exclude_association :reviews
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
  has_many :posts, through: :post_widgets
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

  SECTION_COUNT_QUERY = 'SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?'.freeze

  amoeba do
    enable
    propagate
  end

  def section_count
    ActiveRecord::Base.connection.select_one(SECTION_COUNT_QUERY, id)['section_count']
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
  # Strange bug on rbx
  if defined?(::Rubinius)
    after_initialize :set_type

    def set_type
      self.type = 'Necklace'
    end
  end

  amoeba do
    raised :relaxed
  end
end

class BlackBox < Product
  amoeba do
    propagate :strict
  end
end

class SuperBlackBox < BlackBox
end

# Polymorphism
class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  amoeba do
    enable
  end
end

class Photo < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  amoeba do
    customize(lambda { |original_photo,new_photo|
      new_photo.name = original_photo.name.to_s + ' Copy'
    })
  end
end

class Company < ActiveRecord::Base
  has_many :employees
  has_many :customers

  amoeba do
    include_association :employees
    include_association :customers
  end
end

class Employee < ActiveRecord::Base
  has_many :addresses, as: :addressable
  has_many :photos, as: :imageable
  belongs_to :company

  amoeba do
    include_association :addresses
    include_association :photos
  end

end

class Customer < ActiveRecord::Base
  has_many :addresses, as: :addressable
  has_many :photos, as: :imageable
  belongs_to :company

  amoeba do
    enable
  end
end

# Remapping and Method

class MetalObject < ActiveRecord::Base
end

class ObjectPrototype < MetalObject
  has_many :subobject_prototypes, foreign_key: :parent_id

  amoeba do
    enable
    through :become_real
    remapper :remap_subobjects
  end

  def become_real
    self.dup.becomes RealObject
  end

  def remap_subobjects(relation_name)
    :subobjects if relation_name == :subobject_prototypes
  end
end

class RealObject < MetalObject
  has_many :subobjects, foreign_key: :parent_id
end

class SubobjectPrototype < MetalObject
  amoeba do
    enable
    through :become_subobject
  end

  def become_subobject
    self.dup.becomes Subobject
  end
end

class Subobject < MetalObject
end

# Check of changing boolean attributes

class SuperAdmin < ::ActiveRecord::Base
  amoeba do
    set active: false
    prepend password: false
  end
end

# Proper inheritance

class Box < ActiveRecord::Base
  has_many        :products, class_name: 'BoxProduct'
  has_many        :sub_products, class_name: 'BoxSubProduct'

  amoeba do
    enable
  end
end

class BoxProduct < ActiveRecord::Base
  belongs_to      :box, class_name: 'Box'

  amoeba do
    enable
    propagate
  end
end

class BoxSubProduct < BoxProduct
  has_one :another_product, class_name: 'BoxAnotherProduct'
end

class BoxSubSubProduct < BoxSubProduct
end

class BoxAnotherProduct < BoxProduct
  belongs_to :sub_product, class_name: 'BoxSubProduct'
end

# Inclusion inheritance
class Stage < ActiveRecord::Base
  has_many :listeners
  has_many :specialists

  amoeba do
    include_association :listeners
    include_association :specialists
    nullify :external_id
    propagate
  end
end

class Participant < ActiveRecord::Base
  belongs_to :stage
end

class Listener < Participant
end

class Specialist < Participant
end

class CustomStage < Stage
  has_many :custom_rules, foreign_key: :stage_id

  amoeba do
    include_association :custom_rules
  end
end

class CustomRule < ActiveRecord::Base
  belongs_to :custom_stage
end
