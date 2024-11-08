# frozen_string_literal: true

class Mention < ApplicationRecord
  belongs_to :account, inverse_of: :mentions
  belongs_to :status

  has_one :notification, as: :activity, dependent: :destroy

  validates :account, uniqueness: { scope: :status }

  scope :active, -> { where(silent: false) }
  scope :silent, -> { where(silent: true) }

  delegate(
    :username,
    :acct,
    to: :account,
    prefix: true
  )
end
