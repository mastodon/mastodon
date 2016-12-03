# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  class_methods do
    def cache_associated(*associations)
      @cache_associated = associations
    end
  end

  included do
    scope :with_includes, -> { includes(@cache_associated) }
    scope :cache_ids, -> { select(:id, :updated_at) }
  end
end
