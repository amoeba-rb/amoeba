# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Amoeba::ClassMethods do
  describe '#amoeba' do
    let(:dup) { test.amoeba_dup }
    let(:test) { TestModel.new(**params) }

    before do
      stub_const 'TestModel', Class.new(ActiveRecord::Base)

      ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
      ActiveRecord::Base.connection.schema_cache.clear!

      ActiveRecord::Base.connection.create_table :test_models do |t|
        t.column :test_field, field_type
      end

      TestModel.class_eval config
    end

    describe 'set' do
      context 'with a static string value' do
        let(:params) { { test_field: 'original string' } }
        let(:field_type) { :string }
        let(:config) do
          <<~CONFIG
            amoeba do
              set test_field: 'default string value'
            end
          CONFIG
        end

        it { expect(dup.test_field).to eq('default string value') }
      end

      context 'with a static integer value' do
        let(:params) { { test_field: 33 } }
        let(:field_type) { :integer }
        let(:config) do
          <<~CONFIG
            amoeba do
              set test_field: 99
            end
          CONFIG
        end

        it { expect(dup.test_field).to eq(99) }
      end

      context 'with a static boolean value' do
        let(:params) { { test_field: true } }
        let(:field_type) { :boolean }
        let(:config) do
          <<~CONFIG
            amoeba do
              set test_field: false
            end
          CONFIG
        end

        it { expect(dup.test_field).to be(false) }
      end
    end
  end
end
