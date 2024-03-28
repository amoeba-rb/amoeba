# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'can copy field without modification' do
  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }

  context 'with amoeba explicitly enabled' do
    before { TestModel.class_eval('amoeba { enable }', __FILE__, __LINE__) }

    it { expect(subject.test_field).to eq value }
  end

  context 'without amoeba explicitly enabled' do
    before { TestModel.class_eval('amoeba {}', __FILE__, __LINE__) }

    it { expect(subject.test_field).to eq value }
  end
end

RSpec.shared_examples 'can have a nullified field' do
  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }
  # rubocop:disable Security/Eval
  let(:new_value) { eval(new_value_str) }
  # rubocop:enable Security/Eval

  before { TestModel.class_eval('amoeba { nullify :test_field }', __FILE__, __LINE__) }

  context 'with a field that can be null' do
    let(:db_config) { ->(t) { t.send(field_type, :test_field, null: true) } }

    it { expect(subject.test_field).to be_nil }
  end

  context 'with a field that cannot be null and has a default' do
    let(:db_config) { ->(t) { t.send(field_type, :test_field, null: false, default: new_value) } }

    before { pending 'Bug. See https://github.com/amoeba-rb/amoeba/issues/106' }

    it { expect(subject.test_field).to eq new_value }
  end
end

RSpec.shared_examples 'can have a field set' do
  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }
  # rubocop:disable Security/Eval
  let(:new_value) { eval(new_value_str) }
  # rubocop:enable Security/Eval

  before do
    TestModel.class_eval(
      <<~CONFIG, __FILE__, __LINE__ + 1
        amoeba {
          set test_field: #{new_value_str}    # set test_field: 'Changed'
                                              # set test_field: 9_999_999_999
        }
      CONFIG
    )
  end

  context 'with the field set to a value' do
    it { expect(subject.test_field).to eq new_value }
  end

  context 'with the field set to nil' do
    let(:test_model) { TestModel.create(test_field: nil) }

    it { expect(subject.test_field).to eq new_value }
  end
end

RSpec.shared_examples 'can add a prefix to a field (prepend)' do
  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }

  before { TestModel.class_eval("amoeba { prepend test_field: 'Copy of ' }", __FILE__, __LINE__) }

  context 'when the field is set in the old instance' do
    it { expect(subject.test_field).to eq "Copy of #{value}" }
  end

  context 'with the field is nil in the old instance' do
    let(:value) { nil }

    it { expect(subject.test_field).to eq 'Copy of ' }
  end
end

RSpec.shared_examples 'cannot add a prefix to a field (prepend)' do
  subject(:prepend_config) { TestModel.class_eval("amoeba { prepend test_field: ' (copy)' }", __FILE__, __LINE__) }

  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }

  before { pending 'No validation implemented yet. See https://github.com/amoeba-rb/amoeba/issues/121' }

  # TODO: Create a custom exception
  it { expect { prepend_config }.to raise_error(StandardError) }
end

RSpec.shared_examples 'can add a suffix to a field (append)' do
  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }

  before { TestModel.class_eval("amoeba { append test_field: ' (copy)' }", __FILE__, __LINE__) }

  context 'when the field is set in the old instance' do
    it { expect(subject.test_field).to eq "#{value} (copy)" }
  end

  context 'with the field is nil in the old instance' do
    let(:value) { nil }

    it { expect(subject.test_field).to eq ' (copy)' }
  end
end

RSpec.shared_examples 'cannot add a suffix to a field (append)' do
  subject(:append_config) { TestModel.class_eval("amoeba { append test_field: ' (copy)' }", __FILE__, __LINE__) }

  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }

  before { pending 'No validation implemented yet. See https://github.com/amoeba-rb/amoeba/issues/121' }

  # TODO: Create a custom exception
  it { expect { append_config }.to raise_error(StandardError) }
end

RSpec.shared_examples 'can modify based on a regex' do
  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }
  let(:value) { 'Value one of the string' }

  before { TestModel.class_eval("amoeba { regex test_field: { replace: 'one', with: 'two' } }", __FILE__, __LINE__) }

  context 'when the regex matches' do
    let(:value) { 'Value one of the string' }

    it { expect(subject.test_field).to eq 'Value two of the string' }
  end

  context 'when the regex does not match' do
    let(:value) { 'Value three of the string' }

    it { expect(subject.test_field).to eq 'Value three of the string' }
  end

  context 'when there are multiple matches' do
    let(:value) { 'Value one of one string' }

    it { expect(subject.test_field).to eq 'Value two of two string' }
  end
end

RSpec.shared_examples 'cannot modify based on a regex' do
  subject(:regex_config) do
    TestModel.class_eval("amoeba { regex test_field: { replace: 'one', with: 'two' } }", __FILE__, __LINE__)
  end

  let(:db_config) { ->(t) { t.send(field_type, :test_field) } }

  before { pending 'No validation implemented yet. See https://github.com/amoeba-rb/amoeba/issues/121' }

  # TODO: Create a custom exception
  it { expect { regex_config }.to raise_error(StandardError) }
end

RSpec.describe Amoeba::Cloner do
  subject(:cloner) { described_class.new(original_object) }

  let(:value) { 'test' }
  let(:original_object) { TestModel.create(test_field: value) }
  let(:db_config) { ->(t) { t.string :test_field } }

  before do
    ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.connection.create_table(:test_models, &db_config)

    stub_const 'TestModel', Class.new(ActiveRecord::Base)
  end

  describe '#run' do
    subject(:cloned_object) { cloner.run }

    it { is_expected.to be_a TestModel }

    context 'with a string field' do
      let(:field_type) { :string }
      let(:value) { 'Testing' }
      let(:new_value_str) { "'Changed'" }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'can add a prefix to a field (prepend)'
      it_behaves_like 'can add a suffix to a field (append)'
      it_behaves_like 'can modify based on a regex'
    end

    context 'with a text field' do
      let(:field_type) { :text }
      let(:value) { 'Testing' }
      let(:new_value_str) { "'Changed'" }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'can add a prefix to a field (prepend)'
      it_behaves_like 'can add a suffix to a field (append)'
      it_behaves_like 'can modify based on a regex'
    end

    context 'with a integer field' do
      let(:field_type) { :integer }
      let(:value) { 3 }
      let(:new_value_str) { '9' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a big integer field' do
      let(:field_type) { :bigint }
      let(:value) { 3_333_333_333 }
      let(:new_value_str) { '9_999_999_999' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a float field' do
      let(:field_type) { :float }
      let(:value) { 3.14159 }
      let(:new_value_str) { '1.14121' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a decimal field' do
      let(:field_type) { :decimal }
      let(:value) { 3.14 }
      let(:new_value_str) { '1.14' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a numeric field' do
      let(:field_type) { :numeric }
      let(:value) { 3.14 }
      let(:new_value_str) { '1.14' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a datetime field' do
      let(:field_type) { :datetime }
      let(:value) { DateTime.parse('5 October 2023 15:45') }
      let(:new_value_str) { "DateTime.parse('6 October 2023 16:24')" }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a time field' do
      let(:field_type) { :time }
      let(:value) { Time.parse('15:45') }
      let(:new_value_str) { "Time.parse('16:24')" }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set' do
        before do
          # TODO: Decide if this is correct behaviour
          skip 'Time set correctly but tests fail as date is different'
        end
      end
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a date field' do
      let(:field_type) { :date }
      let(:value) { Date.parse('5 October 2023') }
      let(:new_value_str) { "Date.parse('6 October 2023')" }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a binary field' do
      let(:field_type) { :binary }
      let(:value) { 'abcdefghijklmnopqrstuvwxyz' }
      let(:new_value_str) { "'zyxwvutsrqponmlkjihgfedcba'" }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end

    context 'with a boolean field' do
      let(:field_type) { :boolean }
      let(:value) { false }
      let(:new_value_str) { 'true' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'cannot add a prefix to a field (prepend)'
      it_behaves_like 'cannot add a suffix to a field (append)'
      it_behaves_like 'cannot modify based on a regex'
    end
  end
end
