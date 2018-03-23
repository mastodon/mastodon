# frozen_string_literal: true
# == Schema Information
#
# Table name: follow_requests
#
#  id                :integer          not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :integer          not null
#  target_account_id :integer          not null
#  show_reblogs      :boolean          default(TRUE), not null
#

class FollowRequest < ApplicationRecord
  include Paginable
  include RelationshipCacheable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }

  def authorize!
    account.follow!(target_account, reblogs: show_reblogs)
    MergeWorker.perform_async(target_account.id, account.id)

    destroy!
  end

  alias reject! destroy!
end
