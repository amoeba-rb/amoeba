# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Amoeba::InstanceMethods do
  describe '#amoeba_dup' do
    subject(:copy) { original.amoeba_dup(**options) }

    let(:options) { { name: 'from options' } }

    before do
      ActiveRecord::Schema.define do
        create_table :option_items, force: true do |t|
          t.string :name
        end
        create_table :option_parents, force: true
        create_table :option_children, force: true do |t|
          t.references :option_parent
          t.string :name
        end
      end

      stub_const('OptionItem', Class.new(ActiveRecord::Base) { self.table_name = 'option_items' })

      stub_const('OptionChild', Class.new(ActiveRecord::Base) do
        self.table_name = 'option_children'

        amoeba do
          customize(->(_original, copy, options) { copy.name = options.fetch(:name, 'no options') })
        end
      end)
    end

    context 'when an override lambda takes a third parameter' do
      let(:original) { OptionItem.create(name: 'original') }

      before do
        OptionItem.amoeba do
          override(->(_original, copy, options) { copy.name = options.fetch(:name, 'no options') })
        end
      end

      it { expect(copy.name).to eq 'from options' }

      context 'when no options are given' do
        let(:options) { {} }

        it { expect(copy.name).to eq 'no options' }
      end
    end

    context 'when a customize proc takes a third parameter' do
      let(:original) { OptionItem.create(name: 'original') }

      before do
        OptionItem.amoeba do
          customize(proc { |_original, copy, options| copy.name = options.fetch(:name, 'no options') })
        end
      end

      it { expect(copy.name).to eq 'from options' }

      context 'when no options are given' do
        let(:options) { {} }

        it { expect(copy.name).to eq 'no options' }
      end
    end

    context 'when the third parameter has a default' do
      let(:original) { OptionItem.create(name: 'original') }

      before do
        OptionItem.amoeba do
          customize(->(_original, copy, options = { name: 'default' }) { copy.name = options[:name] })
        end
      end

      it { expect(copy.name).to eq 'from options' }

      context 'when no options are given' do
        let(:options) { {} }

        it { expect(copy.name).to eq 'default' }
      end
    end

    context 'when the blocks take two parameters' do
      let(:original) { OptionItem.create(name: 'original') }

      before do
        OptionItem.amoeba do
          override(->(original, copy) { copy.name = "#{original.name} overridden" })
          customize(proc { |_original, copy| copy.name = "#{copy.name} and customized" })
        end
      end

      it { expect(copy.name).to eq 'original overridden and customized' }

      context 'when no options are given' do
        let(:options) { {} }

        it { expect(copy.name).to eq 'original overridden and customized' }
      end
    end

    context 'when a has_many association is duplicated' do
      let(:original) { OptionParent.create(option_children: [OptionChild.new(name: 'original')]) }

      before do
        stub_const('OptionParent', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_parents'
          has_many :option_children

          amoeba { enable }
        end)
      end

      it { expect(copy.option_children.map(&:name)).to eq ['from options'] }

      context 'when no options are given' do
        let(:options) { {} }

        it { expect(copy.option_children.map(&:name)).to eq ['no options'] }
      end
    end

    context 'when a has_one association is duplicated' do
      let(:original) { OptionParent.create(option_child: OptionChild.new(name: 'original')) }

      before do
        stub_const('OptionParent', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_parents'
          has_one :option_child

          amoeba { enable }
        end)
      end

      it { expect(copy.option_child.name).to eq 'from options' }
    end

    context 'when a has_many :through association is cloned' do
      let(:original) { OptionParent.create(option_children: [OptionChild.create(name: 'original')]) }

      before do
        ActiveRecord::Schema.define do
          create_table :option_links, force: true do |t|
            t.references :option_parent
            t.references :option_child
          end
        end

        stub_const('OptionLink', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_links'
          belongs_to :option_parent
          belongs_to :option_child
        end)

        stub_const('OptionParent', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_parents'
          has_many :option_links
          has_many :option_children, through: :option_links

          amoeba do
            enable
            clone [:option_children]
          end
        end)
      end

      it { expect(copy.option_children.map(&:name)).to eq ['from options'] }
    end

    context 'when a has_and_belongs_to_many association is cloned' do
      let(:original) { OptionParent.create(option_children: [OptionChild.create(name: 'original')]) }

      before do
        ActiveRecord::Schema.define do
          create_table :option_children_parents, id: false, force: true do |t|
            t.references :option_parent
            t.references :option_child
          end
        end

        stub_const('OptionParent', Class.new(ActiveRecord::Base) { self.table_name = 'option_parents' })

        # has_and_belongs_to_many needs the class to have a name when it is declared
        OptionParent.class_eval do
          has_and_belongs_to_many :option_children, join_table: 'option_children_parents'

          amoeba do
            enable
            clone [:option_children]
          end
        end
      end

      it { expect(copy.option_children.map(&:name)).to eq ['from options'] }
    end

    context 'when the associated records have associations of their own' do
      let(:original) do
        OptionParent.create(option_children: [OptionChild.new(option_grandchildren: [OptionGrandchild.new])])
      end

      before do
        ActiveRecord::Schema.define do
          create_table :option_grandchildren, force: true do |t|
            t.references :option_child
            t.string :name
          end
        end

        stub_const('OptionGrandchild', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_grandchildren'

          amoeba do
            customize(->(_original, copy, options) { copy.name = options[:name] })
          end
        end)

        OptionChild.class_eval do
          has_many :option_grandchildren

          amoeba { enable }
        end

        stub_const('OptionParent', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_parents'
          has_many :option_children

          amoeba { enable }
        end)
      end

      it { expect(copy.option_children.flat_map(&:option_grandchildren).map(&:name)).to eq ['from options'] }
    end
  end
end
