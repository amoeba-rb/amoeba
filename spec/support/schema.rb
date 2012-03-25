ActiveRecord::Schema.define do
  self.verbose = false

  create_table :topics, :force => true do |t|
    t.string :title
    t.string :description
    t.timestamps
  end

  create_table :posts, :force => true do |t|
    t.integer :topic_id
    t.integer :owner_id
    t.integer :author_id
    t.string :title
    t.string :contents
    t.timestamps
  end

  create_table :products, :force => true do |t|
    t.string :type
    t.string :title
    t.decimal :price
    t.decimal :weight
    t.decimal :cost
    t.decimal :sleeve
    t.decimal :collar
    t.decimal :length
    t.string :metal
  end

  create_table :products_sections, :force => true do |t|
    t.integer :section_id
    t.integer :product_id
  end

  create_table :sections, :force => true do |t|
    t.string :name
    t.integer :num_employees
    t.decimal :total_sales
  end

  create_table :images, :force => true do |t|
    t.string :filename
    t.integer :product_id
  end

  create_table :employees, :force => true do |t|
    t.string :name
    t.string :ssn
    t.decimal :salary
  end

  create_table :customers, :force => true do |t|
    t.string :email
    t.string :password
    t.decimal :balance
  end

  create_table :addresses, :force => true do |t|
    t.integer :addressable_id
    t.string :addressable_type

    t.string :street
    t.string :unit
    t.string :city
    t.string :state
    t.string :zip
  end

  create_table :post_configs, :force => true do |t|
    t.integer :post_id
    t.integer :is_visible
    t.integer :is_open
    t.string :password
    t.timestamps
  end

  create_table :comments, :force => true do |t|
    t.integer :post_id
    t.string :contents
    t.timestamps
  end

  create_table :custom_things, :force => true do |t|
    t.string :value
    t.timestamps
  end

  create_table :comments, :force => true do |t|
    t.integer :post_id
    t.string :contents
    t.string :nerf
    t.timestamps
  end

  create_table :ratings, :force => true do |t|
    t.integer :comment_id
    t.string :num_stars
    t.timestamps
  end

  create_table :tags, :force => true do |t|
    t.string :value
    t.timestamps
  end

  create_table :users, :force => true do |t|
    t.integer :post_id
    t.string :name
    t.string :email
    t.timestamps
  end

  create_table :authors, :force => true do |t|
    t.string :full_name
    t.string :nickname
    t.timestamps
  end

  create_table :posts_tags, :force => true do |t|
    t.integer :post_id
    t.integer :tag_id
  end

  create_table :notes, :force => true do |t|
    t.string :value
    t.timestamps
  end

  create_table :notes_posts, :force => true do |t|
    t.integer :post_id
    t.integer :note_id
  end

  create_table :widgets, :force => true do |t|
    t.string :value
  end

  create_table :post_widgets, :force => true do |t|
    t.integer :post_id
    t.integer :widget_id
  end

  create_table :categories, :force => true do |t|
    t.string :title
    t.string :description
  end

  create_table :supercats, :force => true do |t|
    t.integer :post_id
    t.integer :category_id
    t.string :ramblings
    t.string :other_ramblings
    t.timestamps
  end

  create_table :superkittens, :force => true do |t|
    t.integer :supercat_id
    t.string :value
    t.timestamps
  end

  create_table :accounts, :force => true do |t|
    t.integer :post_id
    t.string :title
    t.timestamps
  end

  create_table :histories, :force => true do |t|
    t.integer :account_id
    t.string :some_stuff
    t.timestamps
  end
end
