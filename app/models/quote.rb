# frozen_string_literal: true

# == Schema Information
#
# Table name: quotes
#
#  id                :bigint(8)        not null, primary key
#  activity_uri      :string
#  approval_uri      :string
#  state             :integer          default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint(8)        not null
#  quoted_account_id :bigint(8)
#  quoted_status_id  :bigint(8)
#  status_id         :bigint(8)        not null
#
class Quote < ApplicationRecord
  enum :state,
       { pending: 0, accepted: 1, rejected: 2, revoked: 3 },
       validate: true

  belongs_to :status
  belongs_to :quoted_status, class_name: 'Status', optional: true

  belongs_to :account
  belongs_to :quoted_account, class_name: 'Account', optional: true

  before_validation :set_accounts

  validates :activity_uri, presence: true, if: -> { account.local? && quoted_account&.remote? }
  validate :validate_visibility

  def accept!
    update!(state: :accepted)
  end

  def reject!
    if accepted?
      update!(state: :revoked)
    elsif !revoked?
      update!(state: :rejected)
    end
  end

  private

  def set_accounts
    self.account = status.account
    self.quoted_account = quoted_status&.account
  end

  def validate_visibility
    return if account_id == quoted_account_id || quoted_status.nil? || quoted_status.distributable?

    errors.add(:quoted_status_id, :visibility_mismatch)
  end
end
