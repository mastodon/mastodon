# frozen_string_literal: true

# == Schema Information
#
# Table name: status_pins
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  status_id  :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StatusPin < ApplicationRecord
  belongs_to :account
  belongs_to :status

  validates_with StatusPinValidator

  after_destroy :invalidate_cleanup_info, if: %i(account_matches_status_account? account_local?)

  delegate :local?, to: :account, prefix: true

  private

  def invalidate_cleanup_info
    account.statuses_cleanup_policy&.invalidate_last_inspected(status, :unpin)
  end

  def account_matches_status_account?
    status&.account_id == account_id
  end
end
