require 'active_record'
require 'spec_helper'

describe "amoeba" do
  context "dup" do
    it "duplicates associated child records" do
      # Posts {{{
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
      new_post.errors.messages.length.should == 0

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
      end_comment_count.should     == (start_comment_count * 2) + 2
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
      new_post.comments.length.should == 5
      new_post.comments.select{ |c| c.nerf == 'ratatat' && c.contents.nil? }.length.should == 1
      new_post.comments.select{ |c| c.nerf == 'ratatat' }.length.should == 2
      new_post.comments.select{ |c| c.nerf == 'bonk' }.length.should == 1
      new_post.comments.select{ |c| c.nerf == 'bonkers' && c.contents.nil? }.length.should == 1

      new_post.widgets.map(&:id).each do |id|
        old_post.widgets.map(&:id).include?(id).should_not be true
      end
      # }}}
      # Author {{{
      old_author = Author.find(1)
      new_author = old_author.dup
      new_author.save
      new_author.errors.messages.length.should == 0
      # }}}
      # Products {{{
      # Base Class {{{
      old_product = Product.find(1)

      start_image_count = Image.where(:product_id => old_product.id).count
      start_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', old_product.id)
      start_prodsection_count = rs["section_count"]

      new_product = old_product.dup
      new_product.save
      new_product.errors.messages.length.should == 0

      end_image_count = Image.where(:product_id => old_product.id).count
      end_newimage_count = Image.where(:product_id => new_product.id).count
      end_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', 1)
      end_prodsection_count = rs["section_count"]
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', new_product.id)
      end_newprodsection_count = rs["section_count"]

      end_image_count.should == start_image_count
      end_newimage_count.should == start_image_count
      end_section_count.should == start_section_count
      end_prodsection_count.should == start_prodsection_count
      end_newprodsection_count.should == start_prodsection_count
      # }}}

      # Inherited Class {{{
      # Shirt {{{
      old_product = Shirt.find(2)

      start_image_count = Image.where(:product_id => old_product.id).count
      start_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', old_product.id)
      start_prodsection_count = rs["section_count"]

      new_product = old_product.dup
      new_product.save
      new_product.errors.messages.length.should == 0

      end_image_count = Image.where(:product_id => old_product.id).count
      end_newimage_count = Image.where(:product_id => new_product.id).count
      end_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', 1)
      end_prodsection_count = rs["section_count"]
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', new_product.id)
      end_newprodsection_count = rs["section_count"]

      end_image_count.should == start_image_count
      end_newimage_count.should == start_image_count
      end_section_count.should == start_section_count
      end_prodsection_count.should == start_prodsection_count
      end_newprodsection_count.should == start_prodsection_count
      # }}}

      # Necklace {{{
      old_product = Necklace.find(3)

      start_image_count = Image.where(:product_id => old_product.id).count
      start_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', old_product.id)
      start_prodsection_count = rs["section_count"]

      new_product = old_product.dup
      new_product.save
      new_product.errors.messages.length.should == 0

      end_image_count = Image.where(:product_id => old_product.id).count
      end_newimage_count = Image.where(:product_id => new_product.id).count
      end_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', 1)
      end_prodsection_count = rs["section_count"]
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', new_product.id)
      end_newprodsection_count = rs["section_count"]

      end_image_count.should == start_image_count
      end_newimage_count.should == start_image_count
      end_section_count.should == start_section_count
      end_prodsection_count.should == start_prodsection_count
      end_newprodsection_count.should == start_prodsection_count
      # }}}
      # }}}
      # }}}
    end
  end
end
