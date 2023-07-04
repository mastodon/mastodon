# frozen_string_literal: true

class Admin::Metrics::Measure::InstanceMediaAttachmentsMeasure < Admin::Metrics::Measure::BaseMeasure
  include Admin::Metrics::Measure::QueryHelper
  include ActionView::Helpers::NumberHelper

  def self.with_params?
    true
  end

  def key
    'instance_media_attachments'
  end

  def unit
    'bytes'
  end

  def value_to_human_value(value)
    number_to_human_size(value)
  end

  def total_in_time_range?
    false
  end

  protected

  def perform_total_query
    domain = params[:domain]
    domain = Instance.by_domain_and_subdomains(params[:domain]).select(:domain) if params[:include_subdomains]
    MediaAttachment.joins(:account).merge(Account.where(domain: domain)).sum('COALESCE(file_file_size, 0) + COALESCE(thumbnail_file_size, 0)')
  end

  def perform_previous_total_query
    nil
  end

  def sql_array
    [sql_query_string, { start_at: @start_at, end_at: @end_at, domain: params[:domain] }]
  end

  def sql_query_string
    <<~SQL.squish
      SELECT axis.*, (
        WITH new_media_attachments AS (
          SELECT COALESCE(media_attachments.file_file_size, 0) + COALESCE(media_attachments.thumbnail_file_size, 0) AS size
          FROM media_attachments
          INNER JOIN accounts ON accounts.id = media_attachments.account_id
          WHERE date_trunc('day', media_attachments.created_at)::date = axis.period
            AND #{account_domain_sql(params[:include_subdomains])}
        )
        SELECT SUM(size) FROM new_media_attachments
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', :start_at::timestamp)::date, date_trunc('day', :end_at::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL
  end

  def time_period
    (@start_at.to_date..@end_at.to_date)
  end

  def previous_time_period
    ((@start_at.to_date - length_of_period)..(@end_at.to_date - length_of_period))
  end

  def params
    @params.permit(:domain, :include_subdomains)
  end
end
