# frozen_string_literal: true

class FollowRequest < ApplicationRecord
  include Paginable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account, :target_account, presence: true
  validates :account_id, uniqueness: { scope: :target_account_id }

  def authorize!
    account.follow!(target_account)
    FeedManager.instance.merge_into_timeline(target_account, account)
    destroy!
  end

  def reject!
    destroy!
  end
end
