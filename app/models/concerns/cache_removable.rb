# frozen_string_literal: true

module CacheRemovable
  extend ActiveSupport::Concern

  included do
    after_create  self::REMOVE_BLOCKING_CACHE
    after_destroy self::REMOVE_BLOCKING_CACHE
  end

  private

  def remove_blocking_cache(head, *tails)
    tails.each do |tail|
      Rails.cache.delete("#{head}:#{tail}")
    end
  end
end
