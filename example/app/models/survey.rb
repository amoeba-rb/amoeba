# frozen_string_literal: true

class Survey < ActiveRecord::Base
  has_many :sections, inverse_of: :survey

  # enabling here lets amoeba_dup drill down into sections, and from there into questions
  amoeba do
    enable
    prepend title: 'Copy of '
  end
end
