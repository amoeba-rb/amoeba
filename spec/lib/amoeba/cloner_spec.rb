# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Amoeba::Cloner do
  describe '#amoeba_dup' do
    subject(:item_dup) { item.amoeba_dup }

    context 'with nullify set on a field' do
      let(:item) { NullifyDefaultItem.create(field: 'original') }

      before do
        stub_const('NullifyDefaultItem', Class.new(ActiveRecord::Base) do
          self.table_name = 'nullify_default_items'

          amoeba do
            nullify :field
          end
        end)
      end

      context 'when the field does not have a default value and can be null' do
        before do
          ActiveRecord::Schema.define do
            create_table :nullify_default_items, force: true do |t|
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
            create_table :nullify_default_items, force: true do |t|
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
            create_table :nullify_default_items, force: true do |t|
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
            create_table :nullify_default_items, force: true do |t|
              t.string :field, null: false
            end
          end
        end

        it { expect(item_dup.field).to be_nil }
        it { expect { item_dup.save }.to raise_error(ActiveRecord::NotNullViolation) }
      end
    end
  end
end
