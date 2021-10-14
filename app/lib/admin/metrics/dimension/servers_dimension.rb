# frozen_string_literal: true

class Admin::Metrics::Dimension::ServersDimension < Admin::Metrics::Dimension::BaseDimension
  def key
    'servers'
  end

  def data
    sql = <<-SQL.squish
      SELECT accounts.domain, count(*) AS value
      FROM statuses
      INNER JOIN accounts ON accounts.id = statuses.account_id
      WHERE statuses.id BETWEEN $1 AND $2
      GROUP BY accounts.domain
      ORDER BY count(*) DESC
      LIMIT $3
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, Mastodon::Snowflake.id_at(@start_at)], [nil, Mastodon::Snowflake.id_at(@end_at)], [nil, @limit]])

    rows.map { |row| { key: row['domain'] || Rails.configuration.x.local_domain, human_key: row['domain'] || Rails.configuration.x.local_domain, value: row['value'].to_s } }
  end
end
