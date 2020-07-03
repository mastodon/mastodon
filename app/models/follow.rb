# frozen_string_literal: true
# == Schema Information
#
# Table name: follows
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  show_reblogs      :boolean          default(TRUE), not null
#  uri               :string
#  notify            :boolean          default(FALSE), not null
#

class Follow < ApplicationRecord
  include Paginable
  include RelationshipCacheable
  include RateLimitable

  rate_limit by: :account, family: :follows

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }
  validates_with FollowLimitValidator, on: :create, if: :rate_limit?

  scope :recent, -> { reorder(id: :desc) }

  def local?
    false # Force uri_for to use uri attribute
  end

  def revoke_request!
    FollowRequest.create!(account: account, target_account: target_account, show_reblogs: show_reblogs, notify: notify, uri: uri)
    destroy!
  end

  before_validation :set_uri, only: :create
  after_create :increment_cache_counters
  after_create :invalidate_hash_cache
  after_destroy :remove_endorsements
  after_destroy :decrement_cache_counters
  after_destroy :invalidate_hash_cache

  private

  def set_uri
    self.uri = ActivityPub::TagManager.instance.generate_uri_for(self) if uri.nil?
  end

  def remove_endorsements
    AccountPin.where(target_account_id: target_account_id, account_id: account_id).delete_all
  end

  def increment_cache_counters
    account&.increment_count!(:following_count)
    target_account&.increment_count!(:followers_count)
  end

  def decrement_cache_counters
    account&.decrement_count!(:following_count)
    target_account&.decrement_count!(:followers_count)
  end

  def invalidate_hash_cache
    return if account.local? && target_account.local?

    Rails.cache.delete("followers_hash:#{target_account_id}:#{account.synchronization_uri_prefix}")
  end
end
