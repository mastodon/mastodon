# frozen_string_literal: true

module GroupRelationshipCacheable
  extend ActiveSupport::Concern

  included do
    after_commit :remove_group_relationship_cache
  end

  private

  def remove_group_relationship_cache
    Rails.cache.delete("group_relationship:#{account_id}:#{group_id}")
  end
end
