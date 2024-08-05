# frozen_string_literal: true

module Admin::Metrics::Measure::QueryHelper
  protected

  def perform_data_query
    measurement_data_rows.map { |row| { date: row['period'], value: row['value'].to_s } }
  end

  def measurement_data_rows
    ActiveRecord::Base.connection.select_all(sanitized_sql_string)
  end

  def sanitized_sql_string
    ActiveRecord::Base.sanitize_sql_array(sql_array)
  end

  def generated_series_days
    Arel.sql(
      <<~SQL.squish
        SELECT generate_series(:start_at::timestamp, :end_at::timestamp, '1 day')::date AS period
      SQL
    )
  end

  def account_domain_sql(include_subdomains)
    if include_subdomains
      "accounts.domain IN (SELECT domain FROM instances WHERE reverse('.' || domain) LIKE reverse('.' || :domain::text))"
    else
      'accounts.domain = :domain::text'
    end
  end
end
