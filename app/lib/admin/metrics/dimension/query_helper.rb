# frozen_string_literal: true

module Admin::Metrics::Dimension::QueryHelper
  protected

  def dimension_data_rows
    ActiveRecord::Base.connection.select_all(sanitized_sql_string)
  end

  def sanitized_sql_string
    ActiveRecord::Base.sanitize_sql_array(sql_array)
  end
end
