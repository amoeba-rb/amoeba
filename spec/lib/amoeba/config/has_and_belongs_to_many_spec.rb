# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Amoeba::Config, '#has_and_belongs_to_many' do
  subject(:duplicate) { original.amoeba_dup }

  let(:original) { Parent.create(children: [Child.new, Child.new, Child.new]) }
  let(:parent_config) do
    <<~CONFIG
      has_and_belongs_to_many :children

      amoeba { enable }
    CONFIG
  end
  let(:child_config) { 'has_and_belongs_to_many :parents' }

  context 'with has_many association' do
    before do
      ActiveRecord::Base.connection.drop_table :parents, if_exists: true
      ActiveRecord::Base.connection.drop_table :children, if_exists: true
      ActiveRecord::Base.connection.drop_table :children_parents, if_exists: true
      # schema_cache.clear! may not be required with 6.1+
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table :parents
      ActiveRecord::Base.connection.create_table :children
      ActiveRecord::Base.connection.create_table :children_parents, id: false do |t|
        t.belongs_to :parent
        t.belongs_to :child
      end

      stub_const 'Parent', Class.new(ActiveRecord::Base)
      stub_const 'Child', Class.new(ActiveRecord::Base)
      Parent.class_eval parent_config
      Child.class_eval child_config
    end

    context 'with three attached records' do
      it do
        duplicate
        expect { duplicate.save }.not_to change(Child, :count)
      end

      it { expect(duplicate.children.length).to eq 3 }
      it { expect(duplicate.children).to match_array original.children }
    end

    context 'without amoeba enabled' do
      let(:parent_config) { 'has_and_belongs_to_many :children' }

      it { expect(duplicate.children.length).to eq 0 }
    end

    context 'with has_and_belongs_to_many not recognized' do
      let(:parent_config) do
        <<~CONFIG
          has_and_belongs_to_many :children

          amoeba do
            enable
            recognize [:has_one, :has_many]
          end
        CONFIG
      end

      it 'does not include child models in the duplicate' do
        duplicate.save
        expect(duplicate.children).to be_empty
      end
    end

    context 'with cloning' do
      let(:parent_config) do
        <<~CONFIG
          has_and_belongs_to_many :children

          amoeba do
            enable
            clone [:children]
          end
        CONFIG
      end

      it 'does creates new child records' do
        duplicate
        expect { duplicate.save }.to change(Child, :count).by 3
      end

      it 'does not copy the child records from the original' do
        duplicate.save
        expect(duplicate.children.map(&:to_param))
          .not_to match_array(original.children.map(&:to_param))
      end
    end
  end
end
