# frozen_string_literal: true
# == Schema Information
#
# Table name: subscriptions
#
#  id                          :integer          not null, primary key
#  callback_url                :string           default(""), not null
#  secret                      :string
#  expires_at                  :datetime
#  confirmed                   :boolean          default(FALSE), not null
#  account_id                  :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  last_successful_delivery_at :datetime
#  domain                      :string
#

class Subscription < ApplicationRecord
  MIN_EXPIRATION = 1.day.to_i
  MAX_EXPIRATION = 30.days.to_i

  belongs_to :account, required: true

  validates :callback_url, presence: true
  validates :callback_url, uniqueness: { scope: :account_id }

  scope :confirmed, -> { where(confirmed: true) }
  scope :future_expiration, -> { where(arel_table[:expires_at].gt(Time.now.utc)) }
  scope :expired, -> { where(arel_table[:expires_at].lt(Time.now.utc)) }
  scope :active, -> { confirmed.future_expiration }

  def lease_seconds=(value)
    self.expires_at = future_expiration(value)
  end

  def lease_seconds
    (expires_at - Time.now.utc).to_i
  end

  def expired?
    Time.now.utc > expires_at
  end

  before_validation :set_min_expiration

  private

  def future_expiration(value)
    Time.now.utc + future_offset(value).seconds
  end

  def future_offset(seconds)
    [
      [MIN_EXPIRATION, seconds.to_i].max,
      MAX_EXPIRATION,
    ].min
  end

  def set_min_expiration
    self.lease_seconds = 0 unless expires_at
  end
end
