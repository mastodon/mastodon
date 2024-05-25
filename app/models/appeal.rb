# frozen_string_literal: true

# == Schema Information
#
# Table name: appeals
#
#  id                     :bigint(8)        not null, primary key
#  account_id             :bigint(8)        not null
#  account_warning_id     :bigint(8)        not null
#  text                   :text             default(""), not null
#  approved_at            :datetime
#  approved_by_account_id :bigint(8)
#  rejected_at            :datetime
#  rejected_by_account_id :bigint(8)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Appeal < ApplicationRecord
  MAX_STRIKE_AGE = 20.days

  belongs_to :account
  belongs_to :strike, class_name: 'AccountWarning', foreign_key: 'account_warning_id', inverse_of: :appeal
  belongs_to :approved_by_account, class_name: 'Account', optional: true
  belongs_to :rejected_by_account, class_name: 'Account', optional: true

  validates :text, presence: true, length: { maximum: 2_000 }
  validates :account_warning_id, uniqueness: true

  validate :validate_time_frame, on: :create

  scope :approved, -> { where.not(approved_at: nil) }
  scope :rejected, -> { where.not(rejected_at: nil) }
  scope :pending, -> { where(approved_at: nil, rejected_at: nil) }

  def pending?
    !approved? && !rejected?
  end

  def approved?
    approved_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  def approve!(current_account)
    update!(approved_at: Time.now.utc, approved_by_account: current_account)
  end

  def reject!(current_account)
    update!(rejected_at: Time.now.utc, rejected_by_account: current_account)
  end

  def to_log_human_identifier
    account.acct
  end

  def to_log_route_param
    account_warning_id
  end

  private

  def validate_time_frame
    errors.add(:base, I18n.t('strikes.errors.too_late')) if strike.created_at < MAX_STRIKE_AGE.ago
  end
end
