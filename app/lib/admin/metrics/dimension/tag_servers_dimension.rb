# frozen_string_literal: true

class Admin::Metrics::Dimension::TagServersDimension < Admin::Metrics::Dimension::BaseDimension
  def self.with_params?
    true
  end

  def key
    'tag_servers'
  end

  def data
    sql = <<-SQL.squish
      SELECT accounts.domain, count(*) AS value
      FROM statuses
      INNER JOIN accounts ON accounts.id = statuses.account_id
      INNER JOIN statuses_tags ON statuses_tags.status_id = statuses.id
      WHERE statuses_tags.tag_id = $1
        AND statuses.id BETWEEN $2 AND $3
      GROUP BY accounts.domain
      ORDER BY count(*) DESC
      LIMIT $4
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, params[:id]], [nil, Mastodon::Snowflake.id_at(@start_at, with_random: false)], [nil, Mastodon::Snowflake.id_at(@end_at, with_random: false)], [nil, @limit]])

    rows.map { |row| { key: row['domain'] || Rails.configuration.x.local_domain, human_key: row['domain'] || Rails.configuration.x.local_domain, value: row['value'].to_s } }
  end

  private

  def params
    @params.permit(:id)
  end
end
