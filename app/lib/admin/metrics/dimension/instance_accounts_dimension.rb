# frozen_string_literal: true

class Admin::Metrics::Dimension::InstanceAccountsDimension < Admin::Metrics::Dimension::BaseDimension
  include Admin::Metrics::Dimension::QueryHelper
  include LanguagesHelper

  def self.with_params?
    true
  end

  def key
    'instance_accounts'
  end

  protected

  def perform_query
    dimension_data_rows.map { |row| { key: row['username'], human_key: row['username'], value: row['value'].to_s } }
  end

  def sql_array
    [sql_query_string, { domain: params[:domain], limit: @limit }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT accounts.username, count(follows.*) AS value
      FROM accounts
      LEFT JOIN follows ON follows.target_account_id = accounts.id
      WHERE accounts.domain = :domain
      GROUP BY accounts.id, follows.target_account_id
      ORDER BY value DESC
      LIMIT :limit
    SQL
  end

  def params
    @params.permit(:domain)
  end
end
