# frozen_string_literal: true

module DatabaseViewRecord
  extend ActiveSupport::Concern

  class_methods do
    def refresh
      Scenic
        .database
        .refresh_materialized_view(
          table_name,
          concurrently: self::REFRESH_CONCURRENTLY,
          cascade: false
        )
    end
  end

  def readonly?
    true
  end
end
