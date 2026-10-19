# frozen_string_literal: true

require 'spec_helper'

describe Amoeba::Cloner do
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
