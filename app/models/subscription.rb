# frozen_string_literal: true

class Subscription < ApplicationRecord
  MIN_EXPIRATION = 3600 * 24 * 7
  MAX_EXPIRATION = 3600 * 24 * 30

  belongs_to :account, required: true

  validates :callback_url, presence: true
  validates :callback_url, uniqueness: { scope: :account_id }

  scope :active, -> { where(confirmed: true).where('expires_at > ?', Time.now.utc) }

  def lease_seconds=(str)
    self.expires_at = Time.now.utc + [[MIN_EXPIRATION, str.to_i].max, MAX_EXPIRATION].min.seconds
  end

  def lease_seconds
    (expires_at - Time.now.utc).to_i
  end

  before_validation :set_min_expiration

  private

  def set_min_expiration
    self.lease_seconds = 0 unless expires_at
  end
end
