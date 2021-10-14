# frozen_string_literal: true

class Admin::Metrics::Dimension::SourcesDimension < Admin::Metrics::Dimension::BaseDimension
  def key
    'sources'
  end

  def data
    sql = <<-SQL.squish
      SELECT oauth_applications.name, count(*) AS value
      FROM users
      LEFT JOIN oauth_applications ON oauth_applications.id = users.created_by_application_id
      WHERE users.created_at BETWEEN $1 AND $2
      GROUP BY oauth_applications.name
      ORDER BY count(*) DESC
      LIMIT $3
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, @start_at], [nil, @end_at], [nil, @limit]])

    rows.map { |row| { key: row['name'] || 'web', human_key: row['name'] || I18n.t('admin.dashboard.website'), value: row['value'].to_s } }
  end
end
