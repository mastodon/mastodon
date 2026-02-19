# frozen_string_literal: true

module PreloadingConcern
  extend ActiveSupport::Concern

  def preload_collection(scope, klass)
    return scope unless klass.respond_to?(:preload_cacheable_associations)

    scope.to_a.tap do |records|
      klass.preload_cacheable_associations(records)
    end
  end

  def preload_collection_paginated_by_id(scope, klass, limit, options)
    preload_collection scope.to_a_paginated_by_id(limit, options), klass
  end
end
