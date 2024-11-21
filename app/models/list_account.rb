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
  validate :validate_relationship

  before_validation :set_follow, unless: :list_owner_account_is_account?

  private

  def set_follow
    self.follow = Follow.find_by!(account_id: list.account_id, target_account_id: account.id)
  rescue ActiveRecord::RecordNotFound
    self.follow_request = FollowRequest.find_by!(account_id: list.account_id, target_account_id: account.id)
  end

  def validate_relationship
    return if list.account_id == account_id

    errors.add(:account_id, 'follow relationship missing') if follow_id.nil? && follow_request_id.nil?
    errors.add(:follow, 'mismatched accounts') if follow_id.present? && follow.target_account_id != account_id
    errors.add(:follow_request, 'mismatched accounts') if follow_request_id.present? && follow_request.target_account_id != account_id
  end

  def list_owner_account_is_account?
    list.account_id == account_id
  end
end
