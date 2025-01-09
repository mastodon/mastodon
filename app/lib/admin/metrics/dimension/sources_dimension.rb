# frozen_string_literal: true

class Admin::Metrics::Dimension::SourcesDimension < Admin::Metrics::Dimension::BaseDimension
  include Admin::Metrics::Dimension::QueryHelper

  def key
    'sources'
  end

  protected

  def perform_query
    dimension_data_rows.map { |row| { key: row['name'] || 'web', human_key: row['name'] || I18n.t('admin.dashboard.website'), value: row['value'].to_s } }
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at, limit: @limit }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT oauth_applications.name, count(*) AS value
      FROM users
      LEFT JOIN oauth_applications ON oauth_applications.id = users.created_by_application_id
      WHERE users.created_at BETWEEN :start_at AND :end_at
      GROUP BY oauth_applications.name
      ORDER BY count(*) DESC
      LIMIT :limit
    SQL
  end
end
