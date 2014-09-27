require 'spec_helper'

describe 'amoeba' do
  context 'dup' do
    before :each do
      require ::File.dirname(__FILE__) + '/../support/data.rb'
    end
    it 'duplicates associated child records' do
      # Posts {{{
      old_post = ::Post.find(1)
      expect(old_post.comments.map(&:contents).include?('I love it!')).to be_truthy

      old_post.class.amoeba do
        prepend contents: "Here's a copy: "
      end

      new_post = old_post.amoeba_dup

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
      start_posttag_count = rs['tag_count']
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS note_count FROM notes_posts')
      start_postnote_count = rs['note_count']

      expect(new_post.save!).to be_truthy
      expect(new_post.title).to eq("Copy of #{old_post.title}")

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
      end_posttag_count = rs['tag_count']
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS note_count FROM notes_posts')
      end_postnote_count = rs['note_count']

      expect(end_tag_count).to         eq(start_tag_count)
      expect(end_cat_count).to         eq(start_cat_count)
      expect(end_account_count).to     eq(start_account_count * 2)
      expect(end_history_count).to     eq(start_history_count * 2)
      expect(end_supercat_count).to    eq(start_supercat_count * 2)
      expect(end_post_count).to        eq(start_post_count * 2)
      expect(end_comment_count).to     eq((start_comment_count * 2) + 2)
      expect(end_rating_count).to      eq(start_rating_count * 2)
      expect(end_postconfig_count).to  eq(start_postconfig_count * 2)
      expect(end_posttag_count).to     eq(start_posttag_count * 2)
      expect(end_widget_count).to      eq(start_widget_count * 2)
      expect(end_postwidget_count).to  eq(start_postwidget_count * 2)
      expect(end_note_count).to        eq(start_note_count * 2)
      expect(end_postnote_count).to    eq(start_postnote_count * 2)
      expect(end_superkitten_count).to eq(start_superkitten_count * 2)

      expect(new_post.supercats.map(&:ramblings).include?('Copy of zomg')).to be true
      expect(new_post.supercats.map(&:other_ramblings).uniq.length).to eq(1)
      expect(new_post.supercats.map(&:other_ramblings).uniq.include?('La la la')).to be true
      expect(new_post.contents).to eq("Here's a copy: #{old_post.contents.gsub(/dog/, 'cat')} (copied version)")
      expect(new_post.comments.length).to eq(5)
      expect(new_post.comments.select { |c| c.nerf == 'ratatat' && c.contents.nil? }.length).to eq(1)
      expect(new_post.comments.select { |c| c.nerf == 'ratatat' }.length).to eq(2)
      expect(new_post.comments.select { |c| c.nerf == 'bonk' }.length).to eq(1)
      expect(new_post.comments.select { |c| c.nerf == 'bonkers' && c.contents.nil? }.length).to eq(1)

      new_post.widgets.map(&:id).each do |id|
        expect(old_post.widgets.map(&:id).include?(id)).not_to be true
      end

      expect(new_post.custom_things.length).to eq(3)
      expect(new_post.custom_things.select { |ct| ct.value == [] }.length).to eq(1)
      expect(new_post.custom_things.select { |ct| ct.value == [1, 2] }.length).to eq(1)
      expect(new_post.custom_things.select { |ct| ct.value == [78] }.length).to eq(1)
      # }}}
      # Author {{{
      old_author = Author.find(1)
      new_author = old_author.amoeba_dup
      new_author.save!
      expect(new_author.errors.messages.length).to eq(0)
      expect(new_author.posts.first.custom_things.length).to eq(3)
      expect(new_author.posts.first.custom_things.select { |ct| ct.value == [] }.length).to eq(1)
      expect(new_author.posts.first.custom_things.select { |ct| ct.value == [1, 2] }.length).to eq(1)
      expect(new_author.posts.first.custom_things.select { |ct| ct.value == [78] }.length).to eq(1)
      # }}}
      # Products {{{
      # Base Class {{{
      old_product = Product.find(1)

      start_image_count = Image.where(product_id: old_product.id).count
      start_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', old_product.id)
      start_prodsection_count = rs['section_count']

      new_product = old_product.amoeba_dup
      new_product.save
      expect(new_product.errors.messages.length).to eq(0)

      end_image_count = Image.where(product_id: old_product.id).count
      end_newimage_count = Image.where(product_id: new_product.id).count
      end_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', 1)
      end_prodsection_count = rs['section_count']
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', new_product.id)
      end_newprodsection_count = rs['section_count']

      expect(end_image_count).to eq(start_image_count)
      expect(end_newimage_count).to eq(start_image_count)
      expect(end_section_count).to eq(start_section_count)
      expect(end_prodsection_count).to eq(start_prodsection_count)
      expect(end_newprodsection_count).to eq(start_prodsection_count)
      # }}}

      # Inherited Class {{{
      # Shirt {{{
      old_product = Shirt.find(2)

      start_image_count = Image.where(product_id: old_product.id).count
      start_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', old_product.id)
      start_prodsection_count = rs['section_count']

      new_product = old_product.amoeba_dup
      new_product.save
      expect(new_product.errors.messages.length).to eq(0)

      end_image_count = Image.where(product_id: old_product.id).count
      end_newimage_count = Image.where(product_id: new_product.id).count
      end_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', 1)
      end_prodsection_count = rs['section_count']
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', new_product.id)
      end_newprodsection_count = rs['section_count']

      expect(end_image_count).to eq(start_image_count)
      expect(end_newimage_count).to eq(start_image_count)
      expect(end_section_count).to eq(start_section_count)
      expect(end_prodsection_count).to eq(start_prodsection_count)
      expect(end_newprodsection_count).to eq(start_prodsection_count)
      # }}}

      # Necklace {{{
      old_product = Necklace.find(3)

      start_image_count = Image.where(product_id: old_product.id).count
      start_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', old_product.id)
      start_prodsection_count = rs['section_count']

      new_product = old_product.amoeba_dup
      new_product.save
      expect(new_product.errors.messages.length).to eq(0)

      end_image_count = Image.where(product_id: old_product.id).count
      end_newimage_count = Image.where(product_id: new_product.id).count
      end_section_count = Section.all.length
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', 1)
      end_prodsection_count = rs['section_count']
      rs = ActiveRecord::Base.connection.select_one('SELECT COUNT(*) AS section_count FROM products_sections WHERE product_id = ?', new_product.id)
      end_newprodsection_count = rs['section_count']

      expect(end_image_count).to eq(start_image_count)
      expect(end_newimage_count).to eq(start_image_count)
      expect(end_section_count).to eq(start_section_count)
      expect(end_prodsection_count).to eq(start_prodsection_count)
      expect(end_newprodsection_count).to eq(start_prodsection_count)
      # }}}
      # }}}
      # }}}
    end
  end
  context 'override' do
    before :each do
      ::Image.fresh_amoeba
      ::Image.amoeba do
        override ->(old, new) {
          if old.filename == 'test.jpg'
            new.product_id = 13
          end
        }
      end
    end
    it 'should override fields' do
      image = ::Image.create(filename: 'test.jpg', product_id: 12)
      image_dup = image.amoeba_dup
      expect(image_dup.save).to be_truthy
      expect(image_dup.product_id).to eq(13)
    end
    it 'should not override fields' do
      image = ::Image.create(filename: 'test2.jpg', product_id: 12)
      image_dup = image.amoeba_dup
      expect(image_dup.save).to be_truthy
      expect(image_dup.product_id).to eq(12)
    end
  end

  context 'nullify' do
    before :each do
      ::Image.fresh_amoeba
      ::Image.amoeba do
        nullify :product_id
      end
    end
    it 'should nullify fields' do
      image = ::Image.create(filename: 'test.jpg', product_id: 12)
      image_dup = image.amoeba_dup
      expect(image_dup.save).to be_truthy
      expect(image_dup.product_id).to be_nil
    end
  end

  context 'strict propagate' do
    it 'should call #fresh_amoeba' do
      expect(::SuperBlackBox).to receive(:fresh_amoeba).and_call_original
      box = ::SuperBlackBox.create(title: 'Super Black Box', price: 9.99, length: 1, metal: '1')
      new_box = box.amoeba_dup
      expect(new_box.save).to be_truthy
    end
  end

  context 'remapping and custom dup method' do
    let(:prototype) { ObjectPrototype.new }
    context 'through' do
      it do
        real_object = prototype.amoeba_dup
        expect(real_object).to be_a(::RealObject)
      end
    end
    context 'remapper' do
      it do
        prototype.subobject_prototypes << SubobjectPrototype.new
        real_object = prototype.amoeba_dup
        expect(real_object.subobjects.length).to eq(1)
      end
    end
  end

  context 'preprocessing fields' do
    it 'should accept "set" to set false to attribute' do
      super_admin = ::SuperAdmin.create!(email: 'user@example.com', active: true, password: 'password')
      clone = super_admin.amoeba_dup
      expect(clone.active).to eq(false)
    end
    it 'should skip "prepend" if it equal to false' do
      super_admin = ::SuperAdmin.create!(email: 'user2@example.com', active: true, password: 'password')
      clone = super_admin.amoeba_dup
      expect(clone.password).to eq('password')
    end
  end

  context 'inheritance' do
    it 'does not fail with a deep inheritance' do
      box = Box.create
      sub_sub_product = BoxSubSubProduct.create(title: 'Awesome shoes')
      another_product = BoxAnotherProduct.create(title: 'Cleaning product')
      sub_sub_product.box = box
      sub_sub_product.another_product = another_product
      sub_sub_product.save
      expect(box.sub_products.first.another_product.title).to eq('Cleaning product')
      expect(box.amoeba_dup.sub_products.first.another_product.title).to eq('Cleaning product')
    end
  end

end
