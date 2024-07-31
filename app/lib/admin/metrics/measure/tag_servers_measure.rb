# frozen_string_literal: true

class Admin::Metrics::Measure::TagServersMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper

  def self.with_params?
    true
  end

  def key
    'tag_servers'
  end

  protected

  def perform_total_query
    tag.statuses.where('statuses.id BETWEEN ? AND ?', Mastodon::Snowflake.id_at(@start_at, with_random: false), Mastodon::Snowflake.id_at(@end_at, with_random: false)).joins(:account).count('distinct accounts.domain')
  end

  def perform_previous_total_query
    tag.statuses.where('statuses.id BETWEEN ? AND ?', Mastodon::Snowflake.id_at(@start_at - length_of_period, with_random: false), Mastodon::Snowflake.id_at(@end_at - length_of_period, with_random: false)).joins(:account).count('distinct accounts.domain')
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at, tag_id: tag.id, earliest_status_id: earliest_status_id, latest_status_id: latest_status_id }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH tag_servers AS (
          SELECT DISTINCT accounts.domain
          FROM statuses
          INNER JOIN taggings ON statuses.id = taggings.taggable_id AND taggings.taggable_type = 'Status'
          INNER JOIN accounts ON statuses.account_id = accounts.id
          WHERE taggings.tag_id = :tag_id
            AND statuses.id BETWEEN :earliest_status_id AND :latest_status_id
            AND date_trunc('day', statuses.created_at)::date = axis.period
        )
        SELECT COUNT(*) FROM tag_servers
      ) AS value
      FROM (
        #{generated_series_days}
      ) as axis
    SQL
  end

  def earliest_status_id
    Mastodon::Snowflake.id_at(@start_at.beginning_of_day, with_random: false)
  end

  def latest_status_id
    Mastodon::Snowflake.id_at(@end_at.end_of_day, with_random: false)
  end

  def tag
    @tag ||= Tag.find(params[:id])
  end

  def params
    @params.permit(:id)
  end
end
