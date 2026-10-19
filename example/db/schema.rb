# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :surveys, force: true do |t|
    t.string :title
  end

  create_table :sections, force: true do |t|
    t.integer :survey_id
    t.string :title
  end

  create_table :questions, force: true do |t|
    t.integer :section_id
    t.string :text
    t.integer :response_count
  end
end
