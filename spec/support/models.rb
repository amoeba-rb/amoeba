class Topic < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :author, :class_name => 'User'
  has_one :post_config
  has_many :comments
  has_and_belongs_to_many :tags

  amoeba do
    enable
    prepend :title => "Copy of "
    append :contents => " (copied version)"
    regex :contents => {:replace => /dog/, :with => 'cat'}
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
