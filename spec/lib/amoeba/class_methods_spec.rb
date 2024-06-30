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

      context 'with a datetime field set by a lambda' do
        let(:params) { { test_field: DateTime.parse('30 Jun 2024 18:19') } }
        let(:field_type) { :datetime }
        let(:config) do
          <<~CONFIG
            amoeba do
              set test_field: ->() { Time.now }
            end
          CONFIG
        end

        before { travel_to DateTime.parse('1 Jul 2024 09:35') }
        after { travel_back }

        it { expect(dup.test_field).to eq(DateTime.parse('1 Jul 2024 09:35')) }
      end
    end
  end
end
