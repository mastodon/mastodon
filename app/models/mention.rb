# frozen_string_literal: true

class Mention < ApplicationRecord
  belongs_to :account, inverse_of: :mentions, required: true
  belongs_to :status, required: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :account, uniqueness: { scope: :status }
end
