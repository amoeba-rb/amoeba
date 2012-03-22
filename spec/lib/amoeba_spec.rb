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

      start_account_count = Account.all.count
      start_history_count = History.all.count
      start_cat_count = Category.all.count
      start_supercat_count = Supercat.all.count
      start_tag_count = Tag.all.count
      start_note_count = Note.all.count
      start_widget_count = Widget.all.count
      start_post_count = Post.all.count
      start_comment_count = Comment.all.count
      start_rating_count = Rating.all.count
      start_postconfig_count = PostConfig.all.count
      start_postwidget_count = PostWidget.all.count
      start_superkitten_count = Superkitten.all.count
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS tag_count FROM posts_tags')
      start_posttag_count = rs["tag_count"]
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS note_count FROM notes_posts')
      start_postnote_count = rs["note_count"]

      new_post.save

      end_account_count = Account.all.count
      end_history_count = History.all.count
      end_cat_count = Category.all.count
      end_supercat_count = Supercat.all.count
      end_tag_count = Tag.all.count
      end_note_count = Note.all.count
      end_widget_count = Widget.all.count
      end_post_count = Post.all.count
      end_comment_count = Comment.all.count
      end_rating_count = Rating.all.count
      end_postconfig_count = PostConfig.all.count
      end_postwidget_count = PostWidget.all.count
      end_superkitten_count = Superkitten.all.count
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS tag_count FROM posts_tags')
      end_posttag_count = rs["tag_count"]
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS note_count FROM notes_posts')
      end_postnote_count = rs["note_count"]

      end_tag_count.should         == start_tag_count
      end_cat_count.should         == start_cat_count
      end_account_count.should     == start_account_count * 2
      end_history_count.should     == start_history_count * 2
      end_supercat_count.should    == start_supercat_count * 2
      end_post_count.should        == start_post_count * 2
      end_comment_count.should     == (start_comment_count * 2) + 1
      end_rating_count.should      == start_rating_count * 2
      end_postconfig_count.should  == start_postconfig_count * 2
      end_posttag_count.should     == start_posttag_count * 2
      end_widget_count.should      == start_widget_count * 2
      end_postwidget_count.should  == start_postwidget_count * 2
      end_note_count.should        == start_note_count * 2
      end_postnote_count.should    == start_postnote_count * 2
      end_superkitten_count.should == start_superkitten_count * 2

      new_post.supercats.map(&:ramblings).include?("Copy of zomg").should be true
      new_post.supercats.map(&:other_ramblings).uniq.length.should == 1
      new_post.supercats.map(&:other_ramblings).uniq.include?("La la la").should be true
      new_post.title.should == "Copy of #{old_post.title}"
      new_post.contents.should == "Here's a copy: #{old_post.contents.gsub(/dog/, 'cat')} (copied version)"
      new_post.comments.length.should == 4
      new_post.comments.select{ |c| c.nerf == 'ratatat' && c.contents.nil? }.length.should == 1
      new_post.comments.select{ |c| c.nerf == 'ratatat' }.length.should == 2

      new_post.widgets.map(&:id).each do |id|
        old_post.widgets.map(&:id).include?(id).should_not be true
      end
    end
  end
end
