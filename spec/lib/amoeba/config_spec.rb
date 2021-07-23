# frozen_string_literal: true

require 'spec_helper'
require 'pry'

RSpec.shared_examples 'can copy field without modification' do
  context 'with amoeba explicitly enabled' do
    let(:config) { 'amoeba { enable }' }

    it { is_expected.to eq value }
  end

  context 'without amoeba explicitly enabled' do
    let(:config) { 'amoeba {}' }

    it { is_expected.to eq value }
  end
end

RSpec.shared_examples 'can have a nullified field' do
  let(:config) { 'amoeba { nullify :test_field }' }

  context 'with a field that can be null' do
    let(:db_config) { { null: true } }

    it { is_expected.to be_nil }
  end

  context 'with a field that cannot be null and has a default' do
    let(:db_config) { { null: false, default: new_value } }

    before { pending 'Bug. See https://github.com/amoeba-rb/amoeba/issues/106' }

    it { is_expected.to eq new_value }
  end
end

RSpec.shared_examples 'cannot be configured to nullify' do
  let(:config) { 'amoeba { nullify :test_field }' }
  let(:db_config) { { null: false } }

  before { pending 'Bug. Related to https://github.com/amoeba-rb/amoeba/issues/106' }

  # TODO: Use an appropriate error instead of Standard Error
  it { expect { configure }.to raise_error(StandardError) }
end

RSpec.shared_examples 'can have a field set' do
  let(:config) { "amoeba { set test_field: '#{new_value}' }" }

  context 'with the field set to a value' do
    it { is_expected.to eq new_value }
  end

  context 'with the field set to nil' do
    let(:test_model) { TestModel.create(test_field: nil) }

    it { is_expected.to eq new_value }
  end
end

RSpec.shared_examples 'can have a prependable field' do
  let(:config) { "amoeba { prepend test_field: '#{new_value}' }" }

  context 'with the field set to a value' do
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
  let(:config) { "amoeba { append test_field: '#{new_value}' }" }

  context 'with the field set to a value' do
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
  let(:regex_match) { value.to_s[1, 2] }
  let(:config) { "amoeba { regex test_field: { replace: /#{regex_match}/, with: '#{new_value}' } }" }

  context 'with the field set to a value' do
    it { is_expected.to eq "#{value[0]}#{new_value}#{value[3..-1]}" }
  end

  context 'with the field set to nil' do
    before { pending 'Bug. See https://github.com/amoeba-rb/amoeba/issues/107' }

    let(:test_model) { TestModel.create(test_field: nil) }

    it { is_expected.to be_nil }
  end
end

RSpec.shared_examples 'can apply multiple preprocessing directives' do
  let(:regex_match) { value.to_s[1, 2] }
  let(:config) do
    <<~CONFIG
      amoeba do
        prepend test_field: '#{new_value}'
        append test_field: '#{new_value}'
        regex test_field: {replace: /#{regex_match}/, with: '#{new_value}'}
      end
    CONFIG
  end

  it { is_expected.to eq "#{new_value}#{value[0]}#{new_value}#{value[3..-1]}#{new_value}" }
end

RSpec.describe Amoeba::Config do
  let(:db_config) { {} }

  context 'with valid configuration' do
    subject { test_model.amoeba_dup.test_field }

    let(:test_model) { TestModel.create(test_field: value) }

    before do
      ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
      # schema_cache.clear! may not be required with 6.1+
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table(:test_models) { |t| t.send(field, :test_field, **db_config) }

      stub_const 'TestModel', Class.new(ActiveRecord::Base)
      TestModel.class_eval(config)
    end

    context 'with a string field' do
      let(:field) { :string }
      let(:value) { 'Test string' }
      let(:new_value) { 'abc' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'can have a prependable field'
      it_behaves_like 'can have a appendable field'
      it_behaves_like 'can have a field modified by regex'
      it_behaves_like 'can apply multiple preprocessing directives'
    end

    context 'with a text field' do
      let(:field) { :text }
      let(:value) { 'Test text' }
      let(:new_value) { 'abc' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
      it_behaves_like 'can have a prependable field'
      it_behaves_like 'can have a appendable field'
      it_behaves_like 'can have a field modified by regex'
      it_behaves_like 'can apply multiple preprocessing directives'
    end

    context 'with an integer field' do
      let(:field) { :integer }
      let(:value) { 3 }
      let(:new_value) { 6 }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a bigint field' do
      let(:field) { :bigint }
      let(:value) { 3_333_333_333 }
      let(:new_value) { 6_666_666_666 }

      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a float field' do
      let(:field) { :float }
      let(:value) { 3.14159 }
      let(:new_value) { 1.14121 }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a decimal field' do
      let(:field) { :decimal }
      let(:value) { 3.14 }
      let(:new_value) { 1.14 }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a numeric field' do
      let(:field) { :numeric }
      let(:value) { 3.14 }
      let(:new_value) { 1.14 }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a datetime field' do
      let(:field) { :datetime }
      let(:value) { DateTime.parse('19 July 2021 12:29') }
      let(:new_value) { DateTime.parse('5 August 1984 23:59') }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a time field' do
      let(:field) { :time }
      let(:value) { DateTime.parse('19 July 2021 12:29') }
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
      let(:new_value) { DateTime.parse('5 August 1984') }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a binary field' do
      let(:field) { :binary }
      # TODO: Maybe change this sample data into something more realistic as binary data?
      let(:value) { 'abcdefghijklmnopqrstuvwxyz' }
      let(:new_value) { 'nopqrstuvwxyzabcdefghijklm' }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end

    context 'with a boolean field' do
      let(:field) { :boolean }
      let(:value) { false }
      let(:new_value) { true }

      it_behaves_like 'can copy field without modification'
      it_behaves_like 'can have a nullified field'
      it_behaves_like 'can have a field set'
    end
  end

  context 'with invalid configuration' do
    subject(:configure) { TestModel.class_eval(config) }

    let(:db_config) { {} }

    before do
      ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
      # schema_cache.clear! may not be required with 6.1+
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table(:test_models) { |t| t.send(field, :test_field, **db_config) }

      stub_const 'TestModel', Class.new(ActiveRecord::Base)
    end

    context 'with a string field' do
      let(:field) { :string }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a text field' do
      let(:field) { :text }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with an integer field' do
      let(:field) { :integer }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a big integer field' do
      let(:field) { :bigint }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a float field' do
      let(:field) { :float }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a decimal field' do
      let(:field) { :decimal }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a numeric field' do
      let(:field) { :numeric }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a datetime field' do
      let(:field) { :datetime }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a time field' do
      let(:field) { :time }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a date field' do
      let(:field) { :date }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a binary field' do
      let(:field) { :binary }

      it_behaves_like 'cannot be configured to nullify'
    end

    context 'with a boolean field' do
      let(:field) { :boolean }

      it_behaves_like 'cannot be configured to nullify'
    end
  end

  context 'with multiple fields' do
    let(:duplicate) { test_model.amoeba_dup }
    let(:test_model) { TestModel.create(str: 'Test string', txt: 'Test text', num: 3) }

    before do
      ActiveRecord::Base.connection.drop_table :test_models, if_exists: true
      # schema_cache.clear! may not be required with 6.1+
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table :test_models do |t|
        t.string :str
        t.text :txt
        t.integer :num
      end

      stub_const 'TestModel', Class.new(ActiveRecord::Base)
      TestModel.class_eval(config)
    end

    context 'with chained configuration' do
      let(:config) { "amoeba { prepend str: 'Copied string: ', txt: 'Copied text: ' }" }

      it { expect(duplicate.str).to eq 'Copied string: Test string' }
      it { expect(duplicate.txt).to eq 'Copied text: Test text' }
    end

    context 'with a customize preprocessing configuration' do
      let(:config) do
        <<~CONFIG
          amoeba {
            customize(lambda { |original, copied|
              copied.txt = copied.txt + original.str * original.num
            })
            regex txt: { replace: /Test/, with: '????' }
          }
        CONFIG
      end

      it { expect(duplicate.txt).to eq '???? textTest stringTest stringTest string' }
    end

    context 'with multiple customize instructions' do
      let(:config) do
        <<~CONFIG
          amoeba {
            customize([
              lambda { |original, copied|
                copied.num = original.num - 1
              },
              lambda { |original, copied|
                copied.txt = copied.txt + original.str * copied.num
              },
              lambda { |original, copied|
                copied.num = copied.num + 2
              }
            ])
            regex txt: { replace: /Test/, with: '????' }
          }
        CONFIG
      end

      it { expect(duplicate.txt).to eq '???? textTest stringTest string' }
      it { expect(duplicate.num).to eq 4 }
    end

    context 'with an override preprocessing configuration' do
      let(:config) do
        <<~CONFIG
          amoeba {
            override(lambda { |original, copied|
              copied.txt = copied.txt + original.str * original.num
            })
            regex txt: { replace: /Test/, with: '????' }
          }
        CONFIG
      end

      it { expect(duplicate.txt).to eq '???? text???? string???? string???? string' }
    end

    context 'with multiple override instructions' do
      let(:config) do
        <<~CONFIG
          amoeba {
            override([
              lambda { |original, copied|
                copied.num = original.num - 1
              },
              lambda { |original, copied|
                copied.txt = copied.txt + original.str * copied.num
              },
              lambda { |original, copied|
                copied.num = copied.num + 2
              }
            ])
            regex txt: { replace: /Test/, with: '????' }
          }
        CONFIG
      end

      it { expect(duplicate.txt).to eq '???? text???? string???? string' }
      it { expect(duplicate.num).to eq 4 }
    end
  end
end
