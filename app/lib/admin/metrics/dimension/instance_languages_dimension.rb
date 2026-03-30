# frozen_string_literal: true

class Admin::Metrics::Dimension::InstanceLanguagesDimension < Admin::Metrics::Dimension::BaseDimension
  include Admin::Metrics::Dimension::QueryHelper
  include LanguagesHelper

  def self.with_params?
    true
  end

  def key
    'instance_languages'
  end

  protected

  def perform_query
    dimension_data_rows.map { |row| { key: row['language'], human_key: standard_locale_name(row['language']), value: row['value'].to_s } }
  end

  def sql_array
    [sql_query_string, { domain: params[:domain], earliest_status_id:, latest_status_id:, limit: @limit }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT COALESCE(statuses.language, 'und') AS language, count(*) AS value
      FROM statuses
      INNER JOIN accounts ON accounts.id = statuses.account_id
      WHERE accounts.domain = :domain
        AND statuses.id BETWEEN :earliest_status_id AND :latest_status_id
        AND statuses.reblog_of_id IS NULL
      GROUP BY COALESCE(statuses.language, 'und')
      ORDER BY count(*) DESC
      LIMIT :limit
    SQL
  end

  def params
    @params.permit(:domain)
  end
end
