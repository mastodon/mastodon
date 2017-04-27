# frozen_string_literal: true

class FollowRequest < ApplicationRecord
  include Paginable

  belongs_to :account, required: true
  belongs_to :target_account, class_name: 'Account', required: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }

  def authorize!
    account.follow!(target_account)
    MergeWorker.perform_async(target_account.id, account.id)

    destroy!
  end

  def reject!
    destroy!
  end
end
