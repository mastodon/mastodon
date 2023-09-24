# frozen_string_literal: true

# == Schema Information
#
# Table name: scheduled_statuses
#
#  id           :bigint(8)        not null, primary key
#  params       :jsonb
#  scheduled_at :datetime
#  account_id   :bigint(8)        not null
#

class ScheduledStatus < ApplicationRecord
  include Paginable

  TOTAL_LIMIT = 300
  DAILY_LIMIT = 25
  MINIMUM_OFFSET = 5.minutes.freeze

  belongs_to :account, inverse_of: :scheduled_statuses
  has_many :media_attachments, inverse_of: :scheduled_status, dependent: :nullify

  validate :validate_future_date
  validate :validate_total_limit
  validate :validate_daily_limit

  private

  def validate_future_date
    errors.add(:scheduled_at, I18n.t('scheduled_statuses.too_soon')) if scheduled_at.present? && scheduled_at <= Time.now.utc + MINIMUM_OFFSET
  end

  def validate_total_limit
    errors.add(:base, I18n.t('scheduled_statuses.over_total_limit', limit: TOTAL_LIMIT)) if account.scheduled_statuses.count >= TOTAL_LIMIT
  end

  def validate_daily_limit
    errors.add(:base, I18n.t('scheduled_statuses.over_daily_limit', limit: DAILY_LIMIT)) if account.scheduled_statuses.where('scheduled_at::date = ?::date', scheduled_at).count >= DAILY_LIMIT
  end
end
