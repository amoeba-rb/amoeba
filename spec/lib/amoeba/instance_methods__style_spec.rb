# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Amoeba::InstanceMethods do
  describe '#amoeba_dup' do
    let(:original) do
      ParentModel.create(
        name: 'Parent',
        first_child_models: [
          FirstChildModel.create(name: 'First child 1'),
          FirstChildModel.create(name: 'First child 2')
        ],
        second_child_models: [
          SecondChildModel.create(name: 'Second child 1'),
          SecondChildModel.create(name: 'Second child 2')
        ]
      )
    end
    let(:copy) { original.amoeba_dup }

    before do
      ActiveRecord::Base.connection.drop_table :parent_models, if_exists: true
      ActiveRecord::Base.connection.drop_table :first_child_models, if_exists: true
      ActiveRecord::Base.connection.drop_table :second_child_models, if_exists: true
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table(:parent_models) do |t|
        t.string :name
      end
      ActiveRecord::Base.connection.create_table(:first_child_models) do |t|
        t.string :name
        t.references :parent_model
      end
      ActiveRecord::Base.connection.create_table(:second_child_models) do |t|
        t.string :name
        t.references :parent_model
      end

      stub_const 'ParentModel', Class.new(ActiveRecord::Base)
      stub_const 'FirstChildModel', Class.new(ActiveRecord::Base)
      stub_const 'SecondChildModel', Class.new(ActiveRecord::Base)

      ParentModel.class_eval('has_many :first_child_models', __FILE__, __LINE__)
      ParentModel.class_eval('has_many :second_child_models', __FILE__, __LINE__)

      FirstChildModel.class_eval('belongs_to :parent_model', __FILE__, __LINE__)

      SecondChildModel.class_eval('belongs_to :parent_model', __FILE__, __LINE__)
    end

    context 'with indiscriminate style' do
      before { ParentModel.class_eval 'amoeba { enable }', __FILE__, __LINE__ }

      it { expect(copy.first_child_models.map(&:name)).to contain_exactly('First child 1', 'First child 2') }
      it { expect(copy.second_child_models.map(&:name)).to contain_exactly('Second child 1', 'Second child 2') }
    end

    context 'with inclusive style' do
      before do
        ParentModel.class_eval <<~CONFIG, __FILE__, __LINE__ + 1
          amoeba do
            include_association :first_child_models
          end
        CONFIG
      end

      it { expect(copy.first_child_models.map(&:name)).to contain_exactly('First child 1', 'First child 2') }
      it { expect(copy.second_child_models).to be_empty }
    end

    context 'with exclusive style' do
      before do
        ParentModel.class_eval <<~CONFIG, __FILE__, __LINE__ + 1
          amoeba do
            exclude_association :first_child_models
          end
        CONFIG
      end

      it { expect(copy.first_child_models).to be_empty }
      it { expect(copy.second_child_models.map(&:name)).to contain_exactly('Second child 1', 'Second child 2') }
    end
  end
end
