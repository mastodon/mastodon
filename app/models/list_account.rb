# frozen_string_literal: true

# == Schema Information
#
# Table name: list_accounts
#
#  id                :bigint(8)        not null, primary key
#  list_id           :bigint(8)        not null
#  account_id        :bigint(8)        not null
#  follow_id         :bigint(8)
#  follow_request_id :bigint(8)
#

class ListAccount < ApplicationRecord
  belongs_to :list
  belongs_to :account
  belongs_to :follow, optional: true
  belongs_to :follow_request, optional: true

  validates :account_id, uniqueness: { scope: :list_id }

  with_options unless: :list_owner_account_is_account? do
    before_validation :set_follow

    validate :verify_follow_or_follow_request_presence
    validate :verify_follow_target_account, if: :follow_id?
    validate :verify_follow_request_target_account, if: :follow_request_id?
  end

  scope :active, -> { where.not(follow_id: nil) }

  private

  def set_follow
    self.follow = Follow.find_by(account_id: list.account_id, target_account_id: account.id)
    self.follow_request = FollowRequest.find_by(account_id: list.account_id, target_account_id: account.id) if follow.nil?
  end

  def verify_follow_or_follow_request_presence
    errors.add(:account_id, :must_be_following) if follow_id.nil? && follow_request_id.nil?
  end

  def verify_follow_target_account
    errors.add(:follow, :invalid) if follow.target_account_id != account_id
  end

  def verify_follow_request_target_account
    errors.add(:follow_request, :invalid) if follow_request.target_account_id != account_id
  end

  def list_owner_account_is_account?
    list.account_id == account_id
  end
end
