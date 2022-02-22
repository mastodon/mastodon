# frozen_string_literal: true

class Admin::Metrics::Measure::TagServersMeasure < Admin::Metrics::Measure::BaseMeasure
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

  def perform_data_query
    sql = <<-SQL.squish
      SELECT axis.*, (
        SELECT count(distinct accounts.domain) AS value
        FROM statuses
        INNER JOIN statuses_tags ON statuses.id = statuses_tags.status_id
        INNER JOIN accounts ON statuses.account_id = accounts.id
        WHERE statuses_tags.tag_id = $1
          AND statuses.id BETWEEN $2 AND $3
          AND date_trunc('day', statuses.created_at)::date = axis.day
      )
      FROM (
        SELECT generate_series(date_trunc('day', $4::timestamp)::date, date_trunc('day', $5::timestamp)::date, ('1 day')::interval) AS day
      ) as axis
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, params[:id].to_i], [nil, Mastodon::Snowflake.id_at(@start_at, with_random: false)], [nil, Mastodon::Snowflake.id_at(@end_at, with_random: false)], [nil, @start_at], [nil, @end_at]])

    rows.map { |row| { date: row['day'], value: row['value'].to_s } }
  end

  def tag
    @tag ||= Tag.find(params[:id])
  end

  def params
    @params.permit(:id)
  end
end
