# frozen_string_literal: true

class WarmCacheService < BaseService
  def call(cacheable)
    full_item = cacheable.class.where(id: cacheable.id).with_includes.first
    Rails.cache.write(cacheable.cache_key, full_item)
  end
end
