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

    context 'when including a has_rich_text style attribute' do
      subject(:note_dup) { note.amoeba_dup }

      let(:note) do
        RichNote.create(title: 'first').tap { |n| n.create_rich_text_content(body: 'hello') }
      end

      before do
        ActiveRecord::Schema.define do
          create_table :rich_notes, force: true do |t|
            t.string :title
          end

          create_table :rich_text_contents, force: true do |t|
            t.integer :rich_note_id
            t.string :body
          end
        end

        stub_const('RichTextContent', Class.new(ActiveRecord::Base))
        stub_const('RichNote', Class.new(ActiveRecord::Base) do
          self.table_name = 'rich_notes'
          has_one :rich_text_content, class_name: 'RichTextContent', foreign_key: :rich_note_id

          amoeba do
            enable
            include_association :content
          end
        end)
      end

      it 'copies the rich text association' do
        note_dup.save
        expect(note_dup.rich_text_content.body).to eq('hello')
      end

      it 'creates a new record for the copy' do
        note_dup.save
        expect(note_dup.rich_text_content.id).not_to eq(note.rich_text_content.id)
      end
    end

    context 'when no association is listed and has_rich_text style names are used' do
      subject(:note_dup) { note.amoeba_dup }

      let(:note) do
        RichNote.create(title: 'first').tap { |n| n.create_rich_text_content(body: 'hello') }
      end

      before do
        ActiveRecord::Schema.define do
          create_table :rich_notes, force: true do |t|
            t.string :title
          end

          create_table :rich_text_contents, force: true do |t|
            t.integer :rich_note_id
            t.string :body
          end
        end

        stub_const('RichTextContent', Class.new(ActiveRecord::Base))
        stub_const('RichNote', Class.new(ActiveRecord::Base) do
          self.table_name = 'rich_notes'
          has_one :rich_text_content, class_name: 'RichTextContent', foreign_key: :rich_note_id

          amoeba do
            enable
          end
        end)
      end

      it 'copies the association without any include_association' do
        note_dup.save
        expect(note_dup.rich_text_content.body).to eq('hello')
      end
    end
  end
end
