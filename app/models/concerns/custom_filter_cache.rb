# frozen_string_literal: true

module CustomFilterCache
  extend ActiveSupport::Concern

  included do
    after_commit :invalidate_cache!
    before_destroy :prepare_cache_invalidation!
    before_save :prepare_cache_invalidation!

    delegate(
      :invalidate_cache!,
      :prepare_cache_invalidation!,
      to: :custom_filter
    )
  end
end
