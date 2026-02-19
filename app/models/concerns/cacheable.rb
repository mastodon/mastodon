# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    @cache_associated = []

    def cache_associated(*associations)
      @cache_associated = associations
    end

    def with_includes
      includes(@cache_associated)
    end

    def preload_cacheable_associations(records)
      ActiveRecord::Associations::Preloader.new(records: records, associations: @cache_associated).call
    end

    def cache_ids
      select(:id, :updated_at)
    end
  end
end
