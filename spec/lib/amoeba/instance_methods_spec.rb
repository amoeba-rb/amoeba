# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Amoeba::InstanceMethods do
  describe '#amoeba_dup' do
    context 'with options' do
      let(:item) { OptionItem.create(name: 'original') }

      before do
        ActiveRecord::Schema.define do
          create_table :option_items, force: true do |t|
            t.string :name
          end
        end

        stub_const('OptionItem', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_items'
        end)
      end

      context 'when an override block takes a third parameter' do
        before do
          OptionItem.amoeba do
            override(->(_original, copy, options) { copy.name = options.fetch(:name, 'no options') })
          end
        end

        it { expect(item.amoeba_dup(name: 'keywords').name).to eq 'keywords' }
        it { expect(item.amoeba_dup({ name: 'hash' }).name).to eq 'hash' }
        it { expect(item.amoeba_dup.name).to eq 'no options' }
      end

      context 'when a customize block takes a third parameter' do
        before do
          OptionItem.amoeba do
            customize(->(_original, copy, options) { copy.name = options.fetch(:name, 'no options') })
          end
        end

        it { expect(item.amoeba_dup(name: 'keywords').name).to eq 'keywords' }
        it { expect(item.amoeba_dup({ name: 'hash' }).name).to eq 'hash' }
        it { expect(item.amoeba_dup.name).to eq 'no options' }
      end

      context 'when the third parameter is optional' do
        before do
          OptionItem.amoeba do
            customize(->(_original, copy, options = { name: 'default' }) { copy.name = options[:name] })
          end
        end

        it { expect(item.amoeba_dup(name: 'given').name).to eq 'given' }
      end

      context 'when the block takes a splat' do
        before do
          OptionItem.amoeba do
            customize(->(_original, copy, *rest) { copy.name = rest.first[:name] })
          end
        end

        it { expect(item.amoeba_dup(name: 'given').name).to eq 'given' }
      end

      context 'when the blocks take two parameters' do
        before do
          OptionItem.amoeba do
            override(->(original, copy) { copy.name = "#{original.name} overridden" })
            customize(proc { |_original, copy| copy.name = "#{copy.name} and customized" })
          end
        end

        it { expect(item.amoeba_dup.name).to eq 'original overridden and customized' }
        it { expect(item.amoeba_dup(name: 'ignored').name).to eq 'original overridden and customized' }
      end
    end

    context 'with options and associated records' do
      subject(:parent_dup) { parent.amoeba_dup(name: 'from options') }

      before do
        ActiveRecord::Schema.define do
          create_table :option_parents, force: true
          create_table :option_children, force: true do |t|
            t.references :option_parent
            t.string :name
          end
        end

        stub_const('OptionChild', Class.new(ActiveRecord::Base) do
          self.table_name = 'option_children'

          amoeba do
            customize(->(_original, copy, options) { copy.name = options[:name] })
          end
        end)
      end

      context 'when the association is has_many' do
        let(:parent) { OptionParent.create(option_children: [OptionChild.new(name: 'original')]) }

        before do
          stub_const('OptionParent', Class.new(ActiveRecord::Base) do
            self.table_name = 'option_parents'
            has_many :option_children

            amoeba { enable }
          end)
        end

        it { expect(parent_dup.option_children.map(&:name)).to eq ['from options'] }
      end

      context 'when the association is has_one' do
        let(:parent) { OptionParent.create(option_child: OptionChild.new(name: 'original')) }

        before do
          stub_const('OptionParent', Class.new(ActiveRecord::Base) do
            self.table_name = 'option_parents'
            has_one :option_child

            amoeba { enable }
          end)
        end

        it { expect(parent_dup.option_child.name).to eq 'from options' }
      end

      context 'when a has_many :through association is cloned' do
        let(:parent) { OptionParent.create(option_children: [OptionChild.create(name: 'original')]) }

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

        it { expect(parent_dup.option_children.map(&:name)).to eq ['from options'] }
      end

      context 'when a has_and_belongs_to_many association is cloned' do
        let(:parent) { OptionParent.create(option_children: [OptionChild.create(name: 'original')]) }

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

        it { expect(parent_dup.option_children.map(&:name)).to eq ['from options'] }
      end

      context 'when the associated records have associations of their own' do
        let(:parent) do
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

        it do
          expect(parent_dup.option_children.flat_map(&:option_grandchildren).map(&:name)).to eq ['from options']
        end
      end
    end
  end
end
