# frozen_string_literal: true

require 'spec_helper'

describe Amoeba::Cloner do
  subject(:item_dup) { item.amoeba_dup }

  let(:item) { NullifyDefaultItem.create(label: 'custom', code: 'abc', note: 'custom note') }

  before do
    ActiveRecord::Schema.define do
      create_table :nullify_default_items, force: true do |t|
        t.string :label, null: false, default: 'Default label'
        t.string :code, null: false
        t.string :note, default: 'Default note'
      end
    end

    stub_const('NullifyDefaultItem', Class.new(ActiveRecord::Base) do
      self.table_name = 'nullify_default_items'

      amoeba do
        enable
        nullify %i[label note]
      end
    end)
  end

  it 'uses the default for a NOT NULL column that has one' do
    expect(item_dup.label).to eq('Default label')
  end

  it 'sets a nullable column to nil even when it has a default' do
    expect(item_dup.note).to be_nil
  end

  it 'saves the duplicate' do
    expect(item_dup.save).to be(true)
  end
end
