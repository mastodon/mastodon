# frozen_string_literal: true

class Admin::Metrics::Dimension::InstanceAccountsDimension < Admin::Metrics::Dimension::BaseDimension
  include LanguagesHelper

  def self.with_params?
    true
  end

  def key
    'instance_accounts'
  end

  protected

  def perform_query
    sql = <<-SQL.squish
      SELECT accounts.username, count(follows.*) AS value
      FROM accounts
      LEFT JOIN follows ON follows.target_account_id = accounts.id
      WHERE accounts.domain = $1
      GROUP BY accounts.id, follows.target_account_id
      ORDER BY value DESC
      LIMIT $2
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, params[:domain]], [nil, @limit]])

    rows.map { |row| { key: row['username'], human_key: row['username'], value: row['value'].to_s } }
  end

  def params
    @params.permit(:domain)
  end
end
