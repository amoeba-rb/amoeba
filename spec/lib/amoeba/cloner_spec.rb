# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Amoeba::Cloner do
  describe '#amoeba_dup' do
    subject(:item_dup) { item.amoeba_dup }

    before do
      stub_const('TestItem', Class.new(ActiveRecord::Base)) do
        self.table_name = 'test_items'
      end
    end

    context 'with nullify set on a single field' do
      let(:item) { TestItem.create(field: 'original') }

      before do
        TestItem.class_eval do
          amoeba { nullify :field }
        end
      end

      context 'when the field does not have a default value and can be null' do
        before do
          ActiveRecord::Schema.define do
            create_table :test_items, force: true do |t|
              t.string :field
            end
          end
        end

        it { expect(item_dup.field).to be_nil }
        it { expect { item_dup.save }.not_to raise_error }
      end

      context 'when the field has a default value and can be null' do
        before do
          ActiveRecord::Schema.define do
            create_table :test_items, force: true do |t|
              t.string :field, default: 'Default value'
            end
          end
        end

        it { expect(item_dup.field).to be_nil }
        it { expect { item_dup.save }.not_to raise_error }
      end

      context 'when the field has a default value and cannot be null' do
        before do
          ActiveRecord::Schema.define do
            create_table :test_items, force: true do |t|
              t.string :field, null: false, default: 'Default value'
            end
          end
        end

        it { expect(item_dup.field).to eq 'Default value' }
        it { expect { item_dup.save }.not_to raise_error }
      end

      context 'when the field does not have a default value and cannot be null' do
        before do
          ActiveRecord::Schema.define do
            create_table :test_items, force: true do |t|
              t.string :field, null: false
            end
          end
        end

        it { expect(item_dup.field).to be_nil }
        it { expect { item_dup.save }.to raise_error(ActiveRecord::NotNullViolation) }
      end

      context 'when nullify is defined with a true condition' do
        before do
          ActiveRecord::Schema.define do
            create_table :test_items, force: true do |t|
              t.string :field
            end
          end

          TestItem.class_eval do
            fresh_amoeba
            amoeba { nullify :field, if: :condition? }
            def condition? = true
          end
        end

        it { expect(item_dup.field).to be_nil }
        it { expect { item_dup.save }.not_to raise_error }
      end

      context 'when nullify is defined with a false condition' do
        before do
          ActiveRecord::Schema.define do
            create_table :test_items, force: true do |t|
              t.string :field
            end
          end

          TestItem.class_eval do
            fresh_amoeba
            amoeba { nullify :field, if: :condition? }
            def condition? = false
          end
        end

        it { expect(item_dup.field).to eq 'original' }
        it { expect { item_dup.save }.not_to raise_error }
      end

      context 'when a field is redeclared without a condition' do
        before do
          ActiveRecord::Schema.define do
            create_table :test_items, force: true do |t|
              t.string :field
            end
          end

          TestItem.class_eval do
            fresh_amoeba
            amoeba do
              nullify :field, if: :condition?
              nullify :field
            end
            def condition? = false
          end
        end

        it { expect(item_dup.field).to be_nil }
        it { expect { item_dup.save }.not_to raise_error }
      end
    end

    context 'with nullify set on multiple fields' do
      let(:item) do
        TestItem.create(field_one: 'original_one', field_two: 'original_two', field_three: 'original_three')
      end

      before do
        ActiveRecord::Schema.define do
          create_table :test_items, force: true do |t|
            t.string :field_one
            t.string :field_two, default: 'default_two'
            t.string :field_three, null: false, default: 'default_three'
          end
        end

        TestItem.class_eval do
          amoeba { nullify %i[field_one field_two field_three] }
        end
      end

      it { expect(item_dup.field_one).to be_nil }
      it { expect(item_dup.field_two).to be_nil }
      it { expect(item_dup.field_three).to eq 'default_three' }
      it { expect { item_dup.save }.not_to raise_error }

      context 'when an array of fields replaces the previously configured ones' do
        before do
          TestItem.class_eval do
            fresh_amoeba
            amoeba do
              nullify :field_one
              nullify [:field_two]
            end
          end
        end

        it { expect(item_dup.field_one).to eq 'original_one' }
        it { expect(item_dup.field_two).to be_nil }
        it { expect { item_dup.save }.not_to raise_error }
      end

      context 'when an array of fields has a falsey if condition' do
        before do
          TestItem.class_eval do
            fresh_amoeba
            amoeba do
              nullify %i[field_one field_two field_three], if: :condition?
            end
            def condition? = false
          end
        end

        it { expect(item_dup.field_one).to eq 'original_one' }
        it { expect(item_dup.field_two).to eq 'original_two' }
        it { expect(item_dup.field_three).to eq 'original_three' }
        it { expect { item_dup.save }.not_to raise_error }
      end
    end
  end
end
