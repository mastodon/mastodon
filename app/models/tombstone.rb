# frozen_string_literal: true

class Tombstone < ApplicationRecord
  belongs_to :account

  validates :uri, presence: true
end
