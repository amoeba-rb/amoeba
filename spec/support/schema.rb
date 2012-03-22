ActiveRecord::Schema.define do
  self.verbose = false

  create_table :topics, :force => true do |t|
    t.string :title
    t.string :description
    t.timestamps
  end

  create_table :posts, :force => true do |t|
    t.integer :topic_id
    t.integer :author_id
    t.string :title
    t.string :contents
    t.timestamps
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
