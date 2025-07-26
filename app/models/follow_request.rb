# frozen_string_literal: true

# == Schema Information
#
# Table name: follow_requests
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  show_reblogs      :boolean          default(TRUE), not null
#  uri               :string
#  notify            :boolean          default(FALSE), not null
#  languages         :string           is an Array
#

class FollowRequest < ApplicationRecord
  include Paginable
  include RelationshipCacheable
  include RateLimitable
  include FollowLimitable

  rate_limit by: :account, family: :follows

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }
  validates :languages, language: true

  def authorize!
    follow = account.follow!(target_account, reblogs: show_reblogs, notify: notify, languages: languages, uri: uri, bypass_limit: true)

    if account.local?
      ListAccount.where(follow_request: self).update_all(follow_request_id: nil, follow_id: follow.id)
      MergeWorker.perform_async(target_account.id, account.id, 'home')
      MergeWorker.push_bulk(account.owned_lists.with_list_account(target_account).pluck(:id)) do |list_id|
        [target_account.id, list_id, 'list']
      end
    end

    destroy!
  end

  alias reject! destroy!

  def local?
    false # Force uri_for to use uri attribute
  end

  before_validation :set_uri, only: :create
  after_commit :invalidate_follow_recommendations_cache

  private

  def set_uri
    self.uri = ActivityPub::TagManager.instance.generate_uri_for(self) if uri.nil?
  end

  def invalidate_follow_recommendations_cache
    Rails.cache.delete("follow_recommendations/#{account_id}")
  end
end
