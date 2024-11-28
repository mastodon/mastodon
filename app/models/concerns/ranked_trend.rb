# frozen_string_literal: true

module RankedTrend
  extend ActiveSupport::Concern

  included do
    scope :by_rank, -> { order(rank: :desc) }
    scope :ranked_below, ->(value) { where(rank: ..value) }
  end

  class_methods do
    def locales
      distinct.pluck(:language)
    end

    def recalculate_ordered_rank
      connection
        .exec_update(<<~SQL.squish)
          UPDATE #{table_name}
          SET rank = inner_ordered.calculated_rank
          FROM (
            SELECT id, row_number() OVER w AS calculated_rank
            FROM #{table_name}
            WINDOW w AS (
              PARTITION BY language
              ORDER BY score DESC
            )
          ) inner_ordered
          WHERE #{table_name}.id = inner_ordered.id
        SQL
    end
  end
end
