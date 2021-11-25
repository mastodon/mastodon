# frozen_string_literal: true

class Admin::Metrics::Measure::TagServersMeasure < Admin::Metrics::Measure::BaseMeasure
  def self.with_params?
    true
  end

  def key
    'tag_servers'
  end

  def total
    tag.statuses.where('statuses.id BETWEEN ? AND ?', Mastodon::Snowflake.id_at(@start_at, with_random: false), Mastodon::Snowflake.id_at(@end_at, with_random: false)).joins(:account).count('distinct accounts.domain')
  end

  def previous_total
    tag.statuses.where('statuses.id BETWEEN ? AND ?', Mastodon::Snowflake.id_at(@start_at - length_of_period, with_random: false), Mastodon::Snowflake.id_at(@end_at - length_of_period, with_random: false)).joins(:account).count('distinct accounts.domain')
  end

  def data
    sql = <<-SQL.squish
      SELECT axis.*, (
        SELECT count(*) AS value
        FROM statuses
        WHERE statuses.id BETWEEN $1 AND $2
          AND date_trunc('day', statuses.created_at)::date = axis.day
      )
      FROM (
        SELECT generate_series(date_trunc('day', $3::timestamp)::date, date_trunc('day', $4::timestamp)::date, ('1 day')::interval) AS day
      ) as axis
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, Mastodon::Snowflake.id_at(@start_at, with_random: false)], [nil, Mastodon::Snowflake.id_at(@end_at, with_random: false)], [nil, @start_at], [nil, @end_at]])

    rows.map { |row| { date: row['day'], value: row['value'].to_s } }
  end

  protected

  def tag
    @tag ||= Tag.find(params[:id])
  end

  def params
    @params.permit(:id)
  end
end
