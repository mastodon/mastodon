# frozen_string_literal: true

class Admin::Metrics::Dimension::ServersDimension < Admin::Metrics::Dimension::BaseDimension
  include Admin::Metrics::Dimension::QueryHelper

  def key
    'servers'
  end

  protected

  def perform_query
    dimension_data_rows.map { |row| { key: row['domain'] || Rails.configuration.x.local_domain, human_key: row['domain'] || Rails.configuration.x.local_domain, value: row['value'].to_s } }
  end

  def sql_array
    [sql_query_string, { earliest_status_id: earliest_status_id, latest_status_id: latest_status_id, limit: @limit }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT accounts.domain, count(*) AS value
      FROM statuses
      INNER JOIN accounts ON accounts.id = statuses.account_id
      WHERE statuses.id BETWEEN :earliest_status_id AND :latest_status_id
      GROUP BY accounts.domain
      ORDER BY count(*) DESC
      LIMIT :limit
    SQL
  end

  def earliest_status_id
    Mastodon::Snowflake.id_at(@start_at.beginning_of_day, with_random: false)
  end

  def latest_status_id
    Mastodon::Snowflake.id_at(@end_at.end_of_day, with_random: false)
  end
end
