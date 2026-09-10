# frozen_string_literal: true

class Question < ActiveRecord::Base
  belongs_to :section, inverse_of: :questions

  amoeba do
    enable
    nullify :response_count
  end
end
