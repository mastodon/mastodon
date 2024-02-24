# frozen_string_literal: true

module DatabaseViewRecord
  extend ActiveSupport::Concern

  class_methods do
    def refresh
      Scenic.database.refresh_materialized_view(
        table_name,
        concurrently: true,
        cascade: false
      )
    rescue ActiveRecord::StatementInvalid
      Scenic.database.refresh_materialized_view(
        table_name,
        concurrently: false,
        cascade: false
      )
    end
  end

  def readonly?
    true
  end
end
