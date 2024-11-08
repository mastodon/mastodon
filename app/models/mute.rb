# frozen_string_literal: true

class Mute < ApplicationRecord
  include Paginable
  include RelationshipCacheable
  include Expireable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account_id, uniqueness: { scope: :target_account_id }

  after_commit :invalidate_blocking_cache
  after_commit :invalidate_follow_recommendations_cache

  private

  def invalidate_blocking_cache
    Rails.cache.delete("exclude_account_ids_for:#{account_id}")
  end

  def invalidate_follow_recommendations_cache
    Rails.cache.delete("follow_recommendations/#{account_id}")
  end
end
