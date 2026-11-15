# frozen_string_literal: true

class Section < ActiveRecord::Base
  belongs_to :survey, inverse_of: :sections
  has_many :questions, inverse_of: :section

  amoeba do
    enable
  end
end
