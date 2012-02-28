class Topic < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :author, :class_name => 'User'
  has_one :post_config
  has_one :account
  has_one :history, :through => :account
  has_many :comments
  has_many :supercats
  has_many :categories, :through => :supercats
  has_and_belongs_to_many :tags

  amoeba do
    enable
    prepend :title => "Copy of "
    append :contents => " (copied version)"
    regex :contents => {:replace => /dog/, :with => 'cat'}
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
  has_many :posts, :through => :supercats
end

class Supercat < ActiveRecord::Base
  belongs_to :post
  belongs_to :category

  amoeba do
    prepend :ramblings => "Copy of "
  end
end

class PostConfig < ActiveRecord::Base
  belongs_to :post
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

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
end

class User < ActiveRecord::Base
  has_many :posts
end
