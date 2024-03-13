# frozen_string_literal: true

class Admin::Metrics::Dimension::TagLanguagesDimension < Admin::Metrics::Dimension::BaseDimension
  include Admin::Metrics::Dimension::QueryHelper
  include LanguagesHelper

  def self.with_params?
    true
  end

  def key
    'tag_languages'
  end

  protected

  def perform_query
    dimension_data_rows.map { |row| { key: row['language'], human_key: standard_locale_name(row['language']), value: row['value'].to_s } }
  end

  def sql_array
    [sql_query_string, { tag_id: tag_id, earliest_status_id: earliest_status_id, latest_status_id: latest_status_id, limit: @limit }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT COALESCE(statuses.language, 'und') AS language, count(*) AS value
      FROM statuses
      INNER JOIN statuses_tags ON statuses_tags.status_id = statuses.id
      WHERE statuses_tags.tag_id = :tag_id
        AND statuses.id BETWEEN :earliest_status_id AND :latest_status_id
      GROUP BY COALESCE(statuses.language, 'und')
      ORDER BY count(*) DESC
      LIMIT :limit
    SQL
  end

  def tag_id
    params[:id]
  end

  def earliest_status_id
    Mastodon::Snowflake.id_at(@start_at.beginning_of_day, with_random: false)
  end

  def latest_status_id
    Mastodon::Snowflake.id_at(@end_at.end_of_day, with_random: false)
  end

  def params
    @params.permit(:id)
  end
end
