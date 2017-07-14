# frozen_string_literal: true

module RecentOrderable
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { order(arel_table[:id].desc) }
    scope :paginate_by_recent, ->(limit, max_id = nil, since_id = nil) {
      query = recent.limit(limit)
      query = query.where(arel_table[:id].lt(max_id)) if max_id.present?
      query = query.where(arel_table[:id].gt(since_id)) if since_id.present?
      query
    }
  end
end
