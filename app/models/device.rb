# frozen_string_literal: true

class Device < ApplicationRecord
  belongs_to :account

  validates :account, :registration_id, presence: true
end
