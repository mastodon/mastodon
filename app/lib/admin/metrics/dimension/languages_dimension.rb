# frozen_string_literal: true

class Admin::Metrics::Dimension::LanguagesDimension < Admin::Metrics::Dimension::BaseDimension
  include Admin::Metrics::Dimension::QueryHelper
  include LanguagesHelper

  def key
    'languages'
  end

  protected

  def perform_query
    dimension_data_rows.map { |row| { key: row['locale'], human_key: standard_locale_name(row['locale']), value: row['value'].to_s } }
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at, limit: @limit }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT locale, count(*) AS value
      FROM users
      WHERE current_sign_in_at BETWEEN :start_at AND :end_at
        AND locale IS NOT NULL
      GROUP BY locale
      ORDER BY count(*) DESC
      LIMIT :limit
    SQL
  end
end
