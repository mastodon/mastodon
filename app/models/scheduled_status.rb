# frozen_string_literal: true

# == Schema Information
#
# Table name: scheduled_statuses
#
#  id           :bigint(8)        not null, primary key
#  account_id   :bigint(8)
#  scheduled_at :datetime
#  params       :jsonb
#

class ScheduledStatus < ApplicationRecord
  include Paginable

  TOTAL_LIMIT = 300
  DAILY_LIMIT = 25
  MINIMUM_OFFSET = 5.minutes.freeze

  belongs_to :account, inverse_of: :scheduled_statuses
  has_many :media_attachments, inverse_of: :scheduled_status, dependent: :nullify

  scope :scheduled_on_day, ->(date) { where(scheduled_at: date.all_day) }

  validate :validate_future_date, if: :scheduled_at?
  validate :validate_total_limit
  validate :validate_daily_limit

  private

  def validate_future_date
    errors.add(:scheduled_at, I18n.t('scheduled_statuses.too_soon')) if scheduled_too_early?
  end

  def validate_total_limit
    errors.add(:base, I18n.t('scheduled_statuses.over_total_limit', limit: TOTAL_LIMIT)) if over_total_limit?
  end

  def validate_daily_limit
    errors.add(:base, I18n.t('scheduled_statuses.over_daily_limit', limit: DAILY_LIMIT)) if over_daily_limit?
  end

  def over_daily_limit?
    account.scheduled_statuses.scheduled_on_day(scheduled_at).count >= DAILY_LIMIT
  end

  def over_total_limit?
    account.scheduled_statuses.count >= TOTAL_LIMIT
  end

  def scheduled_too_early?
    scheduled_at <= earliest_valid_scheduled_at
  end

  def earliest_valid_scheduled_at
    Time.now.utc + MINIMUM_OFFSET
  end
end
