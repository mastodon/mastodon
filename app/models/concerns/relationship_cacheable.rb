# frozen_string_literal: true

module RelationshipCacheable
  extend ActiveSupport::Concern

  included do
    after_commit :remove_relationship_cache
  end

  private

  def remove_relationship_cache
    Rails.cache.delete(['relationships', account_id, target_account_id])
    Rails.cache.delete(['relationships', target_account_id, account_id])
  end
end
