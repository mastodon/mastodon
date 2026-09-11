# frozen_string_literal: true

class Admin::Metrics::Dimension::TagServersDimension < Admin::Metrics::Dimension::BaseDimension
  include Admin::Metrics::Dimension::QueryHelper

  def self.with_params?
    true
  end

  def key
    'tag_servers'
  end

  protected

  def perform_query
    dimension_data_rows.map { |row| { key: row['domain'] || Rails.configuration.x.local_domain, human_key: row['domain'] || Rails.configuration.x.local_domain, value: row['value'].to_s } }
  end

  def sql_array
    [sql_query_string, { tag_id: tag_id, earliest_status_id:, latest_status_id:, limit: @limit }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT accounts.domain, count(*) AS value
      FROM statuses
      INNER JOIN accounts ON accounts.id = statuses.account_id
      INNER JOIN statuses_tags ON statuses_tags.status_id = statuses.id
      WHERE statuses_tags.tag_id = :tag_id
        AND statuses.id BETWEEN :earliest_status_id AND :latest_status_id
      GROUP BY accounts.domain
      ORDER BY count(*) DESC
      LIMIT :limit
    SQL
  end

  def tag_id
    params[:id]
  end

  def params
    @params.permit(:id)
  end
end
