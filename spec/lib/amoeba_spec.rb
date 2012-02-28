require 'active_record'
require 'spec_helper'

describe "amoeba" do
  context "dup" do
    it "duplicates associated child records" do
      old_post = Post.find(1)
      old_post.comments.map(&:contents).include?("I love it!").should be true

      old_post.class.amoeba do
        prepend :contents => "Here's a copy: "
      end

      new_post = old_post.dup

      start_tag_count = Tag.all.count
      start_post_count = Post.all.count
      start_comment_count = Comment.all.count
      start_rating_count = Rating.all.count
      start_postconfig_count = PostConfig.all.count
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS tag_count FROM posts_tags')
      start_posttag_count = rs["tag_count"]

      new_post.save

      end_tag_count = Tag.all.count
      end_post_count = Post.all.count
      end_comment_count = Comment.all.count
      end_rating_count = Rating.all.count
      end_postconfig_count = PostConfig.all.count
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS tag_count FROM posts_tags')
      end_posttag_count = rs["tag_count"]

      end_tag_count.should         == start_tag_count
      end_post_count.should        == start_post_count * 2
      end_comment_count.should     == start_comment_count * 2
      end_rating_count.should      == start_rating_count * 2
      end_postconfig_count.should  == start_postconfig_count * 2
      end_posttag_count.should     == start_posttag_count * 2

      new_post.title.should == "Copy of #{old_post.title}"
      new_post.contents.should == "Here's a copy: #{old_post.contents.gsub(/dog/, 'cat')} (copied version)"
    end
  end
end
