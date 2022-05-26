# frozen_string_literal: true

class Admin::Metrics::Dimension::InstanceLanguagesDimension < Admin::Metrics::Dimension::BaseDimension
  include LanguagesHelper

  def self.with_params?
    true
  end

  def key
    'instance_languages'
  end

  protected

  def perform_query
    sql = <<-SQL.squish
      SELECT COALESCE(statuses.language, 'und') AS language, count(*) AS value
      FROM statuses
      INNER JOIN accounts ON accounts.id = statuses.account_id
      WHERE accounts.domain = $1
        AND statuses.id BETWEEN $2 AND $3
        AND statuses.reblog_of_id IS NULL
      GROUP BY COALESCE(statuses.language, 'und')
      ORDER BY count(*) DESC
      LIMIT $4
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, params[:domain]], [nil, Mastodon::Snowflake.id_at(@start_at, with_random: false)], [nil, Mastodon::Snowflake.id_at(@end_at, with_random: false)], [nil, @limit]])

    rows.map { |row| { key: row['language'], human_key: standard_locale_name(row['language']), value: row['value'].to_s } }
  end

  def params
    @params.permit(:domain)
  end
end
