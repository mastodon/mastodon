# frozen_string_literal: true

module Paginable
  extend ActiveSupport::Concern

  included do
    scope :paginate_by_max_id, ->(limit, max_id = nil, since_id = nil) {
      query = order(arel_table[:id].desc).limit(limit)
      query = query.where(arel_table[:id].lt(max_id)) if max_id.present?
      query = query.where(arel_table[:id].gt(since_id)) if since_id.present?
      query
    }
  end
end
