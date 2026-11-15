# frozen_string_literal: true

class Survey < ActiveRecord::Base
  has_many :sections, inverse_of: :survey

  amoeba do
    enable
    prepend title: 'Copy of '
  end
end
