# frozen_string_literal: true

require 'spec_helper'

describe 'amoeba' do
  context 'amoeba_dup' do
    before { require ::File.dirname(__FILE__) + '/../support/data.rb' }

    context 'with posts' do
      subject(:save_post) { new_post.save! }

      let(:old_post) { ::Post.find(1) }
      let(:new_post) { old_post.amoeba_dup }

      before do
        old_post.class.amoeba do
          prepend contents: "Here's a copy: "
        end
      end

      # Unecessary. Included in refactor for completeness.
      it { expect(old_post.comments.map(&:contents).include?('I love it!')).to be_truthy }

      it { is_expected.to be_truthy }

      it do
        save_post
        expect(new_post.title).to eq("Copy of #{old_post.title}")
      end

      it { expect { save_post }.not_to change(Tag.all, :count) }
      it { expect { save_post }.not_to change(Category, :count) }

      # The original versions of these tests counted checked that the counts of
      # various models were multipled when the new instance is saved. This
      # depends on there being no other data in the database, which is not
      # reliable. The new versions of these tests check for an increase in the
      # count by a certain amount. This depends on how the test data is created.

      # Testing a 'has_one' relation with default amoeba configuration.
      it { expect { save_post }.to change(Account, :count).by(1) }

      # Testing a 'has_one ... through' relation with default amoeba
      # configuration.
      it { expect { save_post }.to change(History.all, :count).by(1) }

      # Testing a 'has_many' relation with default amoeba configuration.
      it { expect { save_post }.to change(Supercat.all, :count).by(3) }

      # Testing that a new instance is created when a duplicate is saved.
      it { expect { save_post }.to change(Post.all, :count).by(1) }

      # Testing a 'has_one' relation with default amoeba configuration.
      it { expect { save_post }.to change(PostConfig.all, :count).by(1) }

      # The dup adds extra comments based on 'customize'. Three comments are
      # added and two new ones are created.
      it { expect { save_post }.to change(Comment.all, :count).by(5) }

      # Ratings are linked to comments. The dup will duplicate the ratings for
      # the existing comments (6 each for the test data) and the new comments
      # will have no ratings.
      it { expect { save_post }.to change(Rating.all, :count).by(18) }

      # Testing a 'has_and_belongs_to_many' relationship with the default amoeba
      # configuration.
      # The `tag_count` method fetches the number of records in the join table
      # and this tests that the three tags on the post are applied to the new
      # post.
      it { expect { save_post }.to change(Post, :tag_count).by(3) }

      # Testing a 'has_one ... through' relationship with the 'clone' amoeba
      # configuration.
      # The three widgets that are linked, via a join table, should be duplicated
      # in the Widget model and add corresponding records in the join table,
      # PostWidget.
      it { expect { save_post }.to change(Widget.all, :count).by(3) }
      it { expect { save_post }.to change(PostWidget, :count).by(3) }

      # Testing a 'has_and_belongs_to_many' relationship with the 'clone' amoeba
      # configuration.
      # There are three notes attached to the post so three new notes should be
      # created in the Note model as well as three records in the join table. The
      # `note_count` method fetches the number of records in the join table.
      it { expect { save_post }.to change(Note.all, :count).by(3) }
      it { expect { save_post }.to change(Post, :note_count).by(3) }

      # Testing the 'include_association' amoeba configuration.
      # Each Post can have many Supercats and each Supercat can have many
      # Supperkitens. In the test data the post has three supercats and each
      # supercat has three superkittens (how many were there going to St Ives?).
      # As a result 9 extra Superkittens should be generated.
      it { expect { save_post }.to change(Superkitten.all, :count).by(9) }

      # Testing 'prepend' configuration on attribute.
      # The attribute `ramblings` is configured to prepend 'Copy of '.
      it do
        expect(new_post.supercats.map(&:ramblings))
          .to contain_exactly('Copy of zomg', 'Copy of why', 'Copy of ohnoes')
      end

      # Testing 'set' configuration on attribute.
      # The attribute 'other_ramblings' is configured to set to 'La la la'.
      # The original tests check that (a) the values are unique and (b) the value
      # is set correctly. This new test will check that there are three values
      # that are all set the same.
      it { expect(new_post.supercats.map(&:other_ramblings)).to contain_exactly('La la la', 'La la la', 'La la la') }

      # Testing various string modifications.
      #   * 'prepend' to add "Here's a copy: ", defined in the 'before' above
      #   * 'append' to add " (copied version)"
      #   * 'regext' to replace "dog" with "cat"
      it do
        expect(new_post.contents)
          .to eq("Here's a copy: Lorum ipsum dolor rainbow bright. I like cats, cats are awesome. (copied version)")
      end

      # Testing 'customize' configuration.
      # Two of the comments in the old post have 'nerf' values that cause lambdas
      # to generate additional when the post is duplicated.
      # The old post has three comments so the new post will have five comments.
      it { expect(new_post.comments.length).to eq(5) }
      # When the comment's 'nerf' value is 'ratatat' the new post will have the
      # comment duplicated.
      # The 'where' will only work once new_post has been saved.
      it { expect(new_post.tap(&:save).comments.where(nerf: 'ratatat').length).to eq(2) }
      # The duplicate will have a nil 'contents' while the other version is not.
      it { expect(new_post.tap(&:save).comments.where(nerf: 'ratatat', contents: nil).length).to eq(1) }
      # When the comment's 'nerf' value is 'bonk' the new post will have the
      # comment duplicated. The new comment will have a modified 'nerf' value.
      # The 'where' will only work once new_post has been saved.
      # There will only be a single comment with the original 'nerf' value.
      it { expect(new_post.tap(&:save).comments.where(nerf: 'bonk').length).to eq(1) }
      # The duplicate will have a modified 'nerf' value.
      it { expect(new_post.tap(&:save).comments.where(nerf: 'bonkers', contents: nil).length).to eq(1) }

      # Testing duplicates with a 'has_many ... through' reference and a 'clone'
      # amoeba configuration results in new records (with new ids).
      it { expect(old_post.widgets.map(&:id) & new_post.tap(&:save).widgets.map(&:id)).to be_empty }

      # Testing with a value that is serialized with a custom serializer.
      # The 'value' of a CustomThing is a string that is serialized as an array.
      # The test data has three instances of CustomThing; [], [1, 2] and [78]
      it { expect(new_post.tap(&:save).custom_things.pluck(:value)).to contain_exactly([], [1, 2], [78]) }
    end

    context 'with authors' do
      let(:old_author) { Author.find(1) }
      let(:new_author) { old_author.amoeba_dup.tap(&:save!) }

      it { expect(new_author.errors.messages).to be_empty }

      # An author has multiple posts (default amoeba configuration) and posts
      # in turn have multiple custom things (default amoeba configuration). The
      # custom things have a string value field that is serialized via a custom
      # serializer into an array.
      # The test author has three posts, each of which have three custom
      # things. These should be duplicated.
      it { expect(new_author.posts.first.custom_things.map(&:value)).to contain_exactly([], [1, 2], [78]) }
    end

    context 'with inherited classes' do
      # Testing the effect of single-table inheritance on amoeba duplication.
      # The Product class has two subclasses, Shirt and Necklace. Each class
      # has the same amoeba configuration that is defined with the 'raised'
      # option.
      # These tests are copied from the original and I do not fully understand
      # the purpose of some of them as the behavior appears to be the same for
      # all three classes.

      subject(:new_product) { old_product.amoeba_dup.tap(&:save) }

      context 'with the base class' do
        let(:old_product) { Product.find(1) }
        # The base product class has two relations;
        #   * image; has_many with default amoeba configuration
        #   * section; has_and_belongs_to_many with default amoeba configuration
        # The amoeba configuration is defined with the propogate option.

        # Duplicating product does not result in errors.
        it { expect(new_product.errors.messages).to be_empty }

        # New product copies all images from old product. The old product has
        # two images so two new images are created for the new product.
        it { expect { new_product }.to change(Image, :count).by(2) }
        it { expect { new_product }.not_to change(old_product.images, :count) }
        it { expect(new_product.images.count).to eq(old_product.images.count) }

        # New product copies references to all sections from old product. No
        # new sections are created and the new product is linked to the same
        # number of sections as the old product.
        it { expect { new_product }.not_to change(Section.all, :count) }
        it { expect { new_product }.not_to change(old_product, :section_count) }
        it { expect(new_product.section_count).to eq(old_product.section_count) }
      end

      context "with a class inheriting with the 'raised :submissive' configuration" do
        let(:old_product) { Shirt.find(2) }

        # Duplicating product does not result in errors.
        it { expect(new_product.errors.messages).to be_empty }

        # New product copies all images from old product. The old product has
        # two images so two new images are created for the new product.
        it { expect { new_product }.to change(Image, :count).by(2) }
        it { expect { new_product }.not_to change(old_product.images, :count) }
        it { expect(new_product.images.count).to eq(old_product.images.count) }

        # New product copies references to all sections from old product. No
        # new sections are created and the new product is linked to the same
        # number of sections as the old product.
        it { expect { new_product }.not_to change(Section.all, :count) }
        it { expect { new_product }.not_to change(old_product, :section_count) }
        it { expect(new_product.section_count).to eq(old_product.section_count) }
      end

      context "with a class inheriting with the 'raised :relaxed' configuration" do
        let(:old_product) { Necklace.find(3) }

        # Duplicating product does not result in errors.
        it { expect(new_product.errors.messages).to be_empty }

        # New product copies all images from old product. The old product has
        # two images so two new images are created for the new product.
        it { expect { new_product }.to change(Image, :count).by(2) }
        it { expect { new_product }.not_to change(old_product.images, :count) }
        it { expect(new_product.images.count).to eq(old_product.images.count) }

        # New product copies references to all sections from old product. No
        # new sections are created and the new product is linked to the same
        # number of sections as the old product.
        it { expect { new_product }.not_to change(Section.all, :count) }
        it { expect { new_product }.not_to change(old_product, :section_count) }
        it { expect(new_product.section_count).to eq(old_product.section_count) }
      end
    end
  end

  context 'Using a if condition' do
    subject { post.amoeba_dup.save! }

    before(:all) do
      require ::File.dirname(__FILE__) + '/../support/data.rb'
    end

    before { ::Post.fresh_amoeba }

    let(:post) { Post.first }

    it 'includes an association with truthy condition' do
      ::Post.amoeba do
        include_association :comments, if: :truthy?
      end
      expect { subject }.to change(Comment, :count).by(3)
    end

    it 'does not include an association with a falsey condition' do
      ::Post.amoeba do
        include_association :comments, if: :falsey?
      end
      expect { subject }.not_to change(Comment, :count)
    end

    it 'excludes an association with a truthy condition' do
      ::Post.amoeba do
        exclude_association :comments, if: :truthy?
      end
      expect { subject }.not_to change(Comment, :count)
    end

    it 'does not exclude an association with a falsey condition' do
      ::Post.amoeba do
        exclude_association :comments, if: :falsey?
      end
      expect { subject }.to change(Comment, :count).by(3)
    end

    it 'includes associations from a given array with a truthy condition' do
      ::Post.amoeba do
        include_association [:comments], if: :truthy?
      end
      expect { subject }.to change(Comment, :count).by(3)
    end

    it 'does not include associations from a given array with a falsey condition' do
      ::Post.amoeba do
        include_association [:comments], if: :falsey?
      end
      expect { subject }.not_to change(Comment, :count)
    end

    it 'does exclude associations from a given array with a truthy condition' do
      ::Post.amoeba do
        exclude_association [:comments], if: :truthy?
      end
      expect { subject }.not_to change(Comment, :count)
    end

    it 'does not exclude associations from a given array with a falsey condition' do
      ::Post.amoeba do
        exclude_association [:comments], if: :falsey?
      end
      expect { subject }.to change(Comment, :count).by(3)
    end
  end

  context 'when there is an override configured' do
    subject(:image_dup) { image.amoeba_dup }

    let(:image) { Image.create(filename: 'test.jpg', product_id: 12) }

    before do
      Image.fresh_amoeba
      Image.amoeba do
        override ->(old, new) { new.product_id = 13 if old.filename == 'test.jpg' }
      end
    end

    it { is_expected.to be_truthy }
    it { expect(image_dup.product_id).to eq(13) }
  end

  context 'when there is an override configured that does not apply' do
    subject(:image_dup) { image.amoeba_dup }

    let(:image) { Image.create(filename: 'test2.jpg', product_id: 12) }

    before do
      Image.fresh_amoeba
      Image.amoeba do
        override ->(old, new) { new.product_id = 13 if old.filename == 'test.jpg' }
      end
    end

    it { is_expected.to be_truthy }
    it { expect(image_dup.product_id).to eq(12) }
  end

  context 'with a field configured with nullify' do
    subject(:image_dup) { image.amoeba_dup }

    let(:image) { ::Image.create(filename: 'test.jpg', product_id: 12) }

    before { ::Image.fresh_amoeba }

    context 'without a condition' do
      before do
        ::Image.amoeba do
          nullify :product_id
        end
      end

      it { is_expected.to be_truthy }
      it { expect(image_dup.product_id).to be_nil }

      it 'stores the field with no options' do
        expect(::Image.amoeba.null_fields).to eq(product_id: {})
      end
    end

    context 'with a truthy if condition' do
      before do
        ::Image.amoeba do
          nullify :product_id, if: :truthy?
        end
      end

      it { expect(image_dup.product_id).to be_nil }
    end

    context 'with a falsey if condition' do
      before do
        ::Image.amoeba do
          nullify :product_id, if: :falsey?
        end
      end

      it { expect(image_dup.product_id).to eq(12) }

      it 'stores the condition alongside the field' do
        expect(::Image.amoeba.null_fields).to eq(product_id: { if: :falsey? })
      end
    end

    context 'with an array of fields and a falsey if condition' do
      before do
        ::Image.amoeba do
          nullify %i[filename product_id], if: :falsey?
        end
      end

      it { expect(image_dup.filename).to eq('test.jpg') }
      it { expect(image_dup.product_id).to eq(12) }
    end

    context 'when an array of fields replaces the previously configured ones' do
      before do
        ::Image.amoeba do
          nullify :filename
          nullify [:product_id]
        end
      end

      it { expect(image_dup.filename).to eq('test.jpg') }
      it { expect(image_dup.product_id).to be_nil }

      it 'drops the replaced field from null_fields' do
        expect(::Image.amoeba.null_fields).to eq(product_id: {})
      end
    end

    context 'when a field is redeclared without a condition' do
      before do
        ::Image.amoeba do
          nullify :product_id, if: :falsey?
          nullify :product_id
        end
      end

      it { expect(image_dup.product_id).to be_nil }

      it 'clears the previous condition' do
        expect(::Image.amoeba.null_fields).to eq(product_id: {})
      end
    end
  end

  context 'strict propagate' do
    it 'calls #reset_amoeba' do
      allow(SuperBlackBox).to receive(:reset_amoeba).and_call_original
      box = SuperBlackBox.create(title: 'Super Black Box', price: 9.99, length: 1, metal: '1')
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
    subject { super_admin.amoeba_dup }

    let(:super_admin) do
      ::SuperAdmin.create!(email: 'user@example.com', active: true, password: 'password')
    end

    it 'accepts "set" to set false to attribute' do
      expect(subject.active).to be false
    end

    it 'skips "prepend" if it equal to false' do
      expect(subject.password).to eq('password')
    end
  end

  context 'with inheritance' do
    # Box
    #   has_many :products,     class_name: 'BoxProduct'
    #   has_many :sub_products, class_name: 'BoxSubProduct'
    #
    # BoxProduct
    #   belongs_to :box, class_name: 'Box'
    #   amoeba do
    #     enable
    #     propagate
    #   end
    #
    # BoxSubProduct < BoxProduct
    #   has_one :another_product, class_name: 'BoxAnotherProduct'
    #
    # BoxSubSubProduct < BoxSubProduct
    #
    # BoxAnotherProduct < BoxProduct
    #   belongs_to :sub_product, class_name: 'BoxSubProduct'
    #
    # This test, from the original suite, appears to be testing
    #   * BoxProduct has amoeba configured with 'propagate'
    #   * BoxSubProduct inherits (STI) from BoxProduct
    #   * BoxSubSubProduct inherits (STI) from BoxSubProduct
    #
    # When the instance of BoxSubProduct is duplicated as a result of an
    # an instance of Box being duplicated then amoeba also acts on it to make
    # a duplicate of the instance of `another_product`.
    #
    # This test could be improved to also test the behaviour when `propagate`
    # is not used.

    let(:box) { Box.create }
    let(:sub_sub_product) { BoxSubSubProduct.create(title: 'Awesome shoes') }
    let(:another_product) { BoxAnotherProduct.create(title: 'Cleaning product') }

    before { sub_sub_product.update(box: box, another_product: another_product) }

    it { expect(box.amoeba_dup.sub_products.first.another_product.title).to eq('Cleaning product') }
  end

  context 'with inheritance extended' do
    subject(:stage_dup) { stage.amoeba_dup }

    # CustomStage inherits from Stage
    # Stage has amoeba configured with `propagate`
    # These tests are not exactly equivalent to the previous verison. Formerly
    # all the expectations were in a single block and `save!` was executed on
    # the subject. This does not need to be done in some cases.

    let(:stage) { CustomStage.new(title: 'My Stage', external_id: 213) }

    before do
      stage.listeners.build(name: 'John')
      stage.listeners.build(name: 'Helen')
      stage.specialists.build(name: 'Jack')
      stage.custom_rules.build(description: 'Kill all humans')
      stage.save!
    end

    # Stage has the listeners and specialist has_many attributes configured
    # with amoeba with `include_association`. This is inherited by CustomStage.
    it { expect { stage_dup.save! }.to change(Listener, :count).by(2) }
    it { expect(stage_dup.tap(&:save!).listeners.find_by(name: 'John')).not_to be_nil }
    it { expect(stage_dup.tap(&:save!).listeners.find_by(name: 'Helen')).not_to be_nil }
    it { expect { stage_dup.save! }.to change(Specialist, :count).by(1) }
    it { expect(stage_dup.tap(&:save!).specialists.find_by(name: 'Jack')).not_to be_nil }

    # CustomStage has the custom_rules has_many attribute configured with
    # amoeba with `include_association`. This attribute does not exist for
    # Stage.
    it { expect { stage_dup.save! }.to change(CustomRule, :count).by(1) }
    # save! is not required here as it is testing the unsaved instance of
    # CustomRule. This differs from the tests above for listeners and
    # specialists which uses find_by. This is testing the same thing but needs
    # the instances to be in the database.
    it { expect(stage_dup.custom_rules.first.description).to eq 'Kill all humans' }

    # Stage has an attribute title that is not explicitly configured for amoeba
    # and so has the default configuration. CustomStage inherits this
    # configuration.
    it { expect(stage_dup.title).to eq 'My Stage' }

    # Stage has an attribute external_id that is configured for amoeba with
    # nullify. CustomStage inherits this configuration.
    it { expect(stage_dup.external_id).to be_nil }
  end

  context 'polymorphic' do
    let(:company) { Company.find_by(name: 'ABC Industries') }
    let(:new_company) { company.amoeba_dup }

    it 'does not fail with a deep inheritance' do
      # employee = company.employees.where(name:'Joe').first
      start_company_count = Company.count
      start_customer_count = Customer.count
      start_employee_count = Employee.count
      start_address_count = Address.count
      start_photo_count = Photo.count
      new_company.name = "Copy of #{new_company.name}"
      new_company.save
      expect(Company.count).to eq(start_company_count + 1)
      expect(Customer.count).to eq(start_customer_count + 1)
      expect(Employee.count).to eq(start_employee_count + 1)
      expect(Address.count).to eq(start_address_count + 4)
      expect(Photo.count).to eq(start_photo_count + 2)

      new_company.reload # fully reload from database
      new_company_employees = new_company.employees
      expect(new_company_employees.count).to eq(1)
      new_company_employee_joe = new_company_employees.find_by(name: 'Joe')
      expect(new_company_employee_joe.photos.count).to eq(1)
      expect(new_company_employee_joe.photos.first.size).to eq(12_345)
      expect(new_company_employee_joe.addresses.count).to eq(2)
      expect(new_company_employee_joe.addresses.where(street: '123 My Street').count).to eq(1)
      expect(new_company_employee_joe.addresses.where(street: '124 My Street').count).to eq(1)
      new_company_customers = new_company.customers
      expect(new_company_customers.count).to eq(1)
      new_company_customer_my = new_company_customers.where(email: 'my@email.address').first
      expect(new_company_customer_my.photos.count).to eq(1)
      expect(new_company_customer_my.photos.first.size).to eq(54_321)
      expect(new_company_customer_my.addresses.count).to eq(2)
      expect(new_company_customer_my.addresses.where(street: '321 My Street').count).to eq(1)
      expect(new_company_customer_my.addresses.where(street: '321 My Drive').count).to eq(1)
    end
  end
end
