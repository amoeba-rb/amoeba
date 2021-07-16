# frozen_string_literal: true

require 'spec_helper'
require 'pry'

RSpec.shared_examples 'can copy field without modification' do
  subject { duplicate.test_field }

  let(:test_model) { TestModel.create(test_field: value) }

  before do
    ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
    # schema_cache.clear! may not be required with 6.1+
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.connection.create_table :test_models do |t|
      t.send(field, :test_field, null: true)
    end

    stub_const 'TestModel', Class.new(ActiveRecord::Base)
    TestModel.class_eval(config)
  end

  context 'with amoeba explicitly enabled' do
    let(:config) { 'amoeba { enable }' }

    it { is_expected.to eq value }
  end

  context 'wthout amoeba explicitly enabled' do
    let(:config) { 'amoeba {}' }

    it { is_expected.to eq value }
  end
end

RSpec.shared_examples 'can have a nullified field' do
  subject { duplicate.test_field }

  context 'with a field that can be null' do
    let(:test_model) { TestModel.create(test_field: value) }

    before do
      ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
      # schema_cache.clear! may not be required with 6.1+
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table :test_models do |t|
        t.send(field, :test_field, null: true)
      end

      stub_const 'TestModel', Class.new(ActiveRecord::Base)
      TestModel.class_eval { amoeba { nullify :test_field } }
    end

    it { is_expected.to be_nil }
  end

  context 'with a field that cannot be null and has a default' do
    let(:test_model) { TestModel.create(test_field: value) }

    before do
      pending 'Bug. See https://github.com/amoeba-rb/amoeba/issues/106'

      ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
      # schema_cache.clear! may not be required with 6.1+
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table :test_models do |t|
        t.send(field, :test_field, null: false, default: default_value)
      end

      stub_const 'TestModel', Class.new(ActiveRecord::Base)
      TestModel.class_eval { amoeba { nullify :test_field } }
    end

    it { is_expected.to eq default_value }
  end

  context 'with a field that cannot be null and does not have a default' do
    let(:test_model) { TestModel.create(test_field: value) }

    before do
      pending 'Bug. Related to https://github.com/amoeba-rb/amoeba/issues/106'

      ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
      # schema_cache.clear! may not be required with 6.1+
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table :test_models do |t|
        t.send(field, :test_field, null: false)
      end

      stub_const 'TestModel', Class.new(ActiveRecord::Base)
    end

    it 'cannot be configured to nullify' do
      # TODO: Use an appropriate error instead of Standard Error
      expect { TestModel.class_eval { amoeba { nullify :test_field } } }
        .to raise_error(StandardError)
    end
  end
end

RSpec.shared_examples 'can have a field set' do
  subject { duplicate.test_field }

  let(:config) { "amoeba { set test_field: '#{new_value}' }" }

  before do
    ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
    # schema_cache.clear! may not be required with 6.1+
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.connection.create_table :test_models do |t|
      t.send(field, :test_field, null: true)
    end

    stub_const 'TestModel', Class.new(ActiveRecord::Base)
    TestModel.class_eval(config)
  end

  context 'with the field set to a value' do
    let(:test_model) { TestModel.create(test_field: value) }

    it { is_expected.to eq new_value }
  end

  context 'with the field set to nil' do
    let(:test_model) { TestModel.create(test_field: nil) }

    it { is_expected.to eq new_value }
  end
end

RSpec.shared_examples 'can have a prependable field' do
  subject { duplicate.test_field }

  let(:config) { "amoeba { prepend test_field: '#{new_value}' }" }

  before do
    ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
    # schema_cache.clear! may not be required with 6.1+
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.connection.create_table :test_models do |t|
      t.send(field, :test_field, null: true)
    end

    stub_const 'TestModel', Class.new(ActiveRecord::Base)
    TestModel.class_eval(config)
  end

  context 'with the field set to a value' do
    let(:test_model) { TestModel.create(test_field: value) }

    it { is_expected.to eq "#{new_value}#{value}" }
  end

  context 'with the field set to nil' do
    # TODO: Decide on the correct behaviour.
    #       Should a null value be 'prepended', resulting in a non-null value?
    let(:test_model) { TestModel.create(test_field: nil) }

    it { is_expected.to eq new_value }
  end
end

RSpec.shared_examples 'can have a appendable field' do
  subject { duplicate.test_field }

  let(:config) { "amoeba { append test_field: '#{new_value}' }" }

  before do
    ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
    # schema_cache.clear! may not be required with 6.1+
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.connection.create_table :test_models do |t|
      t.send(field, :test_field, null: true)
    end

    stub_const 'TestModel', Class.new(ActiveRecord::Base)
    TestModel.class_eval(config)
  end

  context 'with the field set to a value' do
    let(:test_model) { TestModel.create(test_field: value) }

    it { is_expected.to eq "#{value}#{new_value}" }
  end

  context 'with the field set to nil' do
    # TODO: Decide on the correct behaviour.
    #       Should a null value be 'appended', resulting in a non-null value?
    let(:test_model) { TestModel.create(test_field: nil) }

    it { is_expected.to eq new_value }
  end
end

RSpec.shared_examples 'can have a field modified by regex' do
  subject { duplicate.test_field }

  let(:regex_match) { value.to_s[1, 2] }
  let(:config) { "amoeba { regex test_field: { replace: /#{regex_match}/, with: '#{new_value}' } }" }

  before do
    ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
    # schema_cache.clear! may not be required with 6.1+
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.connection.create_table :test_models do |t|
      t.send(field, :test_field, null: true)
    end

    stub_const 'TestModel', Class.new(ActiveRecord::Base)
    TestModel.class_eval(config)
  end

  context 'with the field set to a value' do
    let(:test_model) { TestModel.create(test_field: value) }

    it { is_expected.to eq "#{value[0]}#{new_value}#{value[3..-1]}" }
  end

  context 'with the field set to nil' do
    before { pending 'Bug. See https://github.com/amoeba-rb/amoeba/issues/107' }

    let(:test_model) { TestModel.create(test_field: nil) }

    it { is_expected.to be_nil }
  end
end

RSpec.describe Amoeba::Config do
  subject(:duplicate) { test_model.amoeba_dup }

  context 'with a string field' do
    let(:field) { :string }
    let(:value) { 'Test string' }
    let(:default_value) { 'Test default value' }
    let(:new_value) { 'abc' }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
    it_behaves_like 'can have a prependable field'
    it_behaves_like 'can have a appendable field'
    it_behaves_like 'can have a field modified by regex'
  end

  context 'with a text field' do
    let(:field) { :text }
    let(:value) { 'Test string' }
    let(:default_value) { 'Test default value' }
    let(:new_value) { 'abc' }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
    it_behaves_like 'can have a prependable field'
    it_behaves_like 'can have a appendable field'
    it_behaves_like 'can have a field modified by regex'
  end

  context 'with an integer field' do
    let(:field) { :integer }
    let(:value) { 3 }
    let(:default_value) { 9 }
    let(:new_value) { 6 }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a big integer field' do
    let(:field) { :bigint }
    let(:value) { 3_333_333_333 }
    let(:default_value) { 9_999_999_999 }
    let(:new_value) { 6_666_666_666 }

    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a float field' do
    let(:field) { :float }
    let(:value) { 3.14159 }
    let(:default_value) { 2.71828 }
    let(:new_value) { 1.14121 }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a decimal field' do
    let(:field) { :decimal }
    let(:value) { 3.14 }
    let(:default_value) { 2.72 }
    let(:new_value) { 1.14 }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a numeric field' do
    let(:field) { :numeric }
    let(:value) { 3.14 }
    let(:default_value) { 2.72 }
    let(:new_value) { 1.14 }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a datetime field' do
    let(:field) { :datetime }
    let(:value) { DateTime.parse('19 July 2021 12:29') }
    let(:default_value) { DateTime.parse('1 July 2021 9:00') }
    let(:new_value) { DateTime.parse('5 August 1984 23:59') }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a time field' do
    let(:field) { :time }
    let(:value) { DateTime.parse('19 July 2021 12:29') }
    let(:default_value) { DateTime.parse('1 July 2021 9:00') }
    let(:new_value) { DateTime.parse('5 August 1984 23:59') }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set' do
      before { skip 'Check issue with setting time field' }
    end
  end

  context 'with a date field' do
    let(:field) { :date }
    let(:value) { DateTime.parse('19 July 2021') }
    let(:default_value) { DateTime.parse('1 July 2021') }
    let(:new_value) { DateTime.parse('5 August 1984') }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a binary field' do
    let(:field) { :binary }
    # TODO: Maybe change this sample data into something more realistic as binary data?
    let(:value) { 'abcdefghijklmnopqrstuvwxyz' }
    let(:default_value) { 'zyxwvutsrqponmlkjihgfedcba' }
    let(:new_value) { 'nopqrstuvwxyzabcdefghijklm' }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end

  context 'with a boolean field' do
    let(:field) { :boolean }
    let(:value) { false }
    let(:default_value) { true }
    let(:new_value) { true }

    it_behaves_like 'can copy field without modification'
    it_behaves_like 'can have a nullified field'
    it_behaves_like 'can have a field set'
  end
end
