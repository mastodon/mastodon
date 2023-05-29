# frozen_string_literal: true

class Admin::Metrics::Measure::InstanceMediaAttachmentsMeasure < Admin::Metrics::Measure::BaseMeasure
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

  def perform_data_query
    account_matching_sql = begin
      if params[:include_subdomains]
        "accounts.domain IN (SELECT domain FROM instances WHERE reverse('.' || domain) LIKE reverse('.' || $3::text))"
      else
        'accounts.domain = $3::text'
      end
    end

    sql = <<-SQL.squish
      SELECT axis.*, (
        WITH new_media_attachments AS (
          SELECT COALESCE(media_attachments.file_file_size, 0) + COALESCE(media_attachments.thumbnail_file_size, 0) AS size
          FROM media_attachments
          INNER JOIN accounts ON accounts.id = media_attachments.account_id
          WHERE date_trunc('day', media_attachments.created_at)::date = axis.period
            AND #{account_matching_sql}
        )
        SELECT SUM(size) FROM new_media_attachments
      ) AS value
      FROM (
        SELECT generate_series(date_trunc('day', $1::timestamp)::date, date_trunc('day', $2::timestamp)::date, interval '1 day') AS period
      ) AS axis
    SQL

    rows = ActiveRecord::Base.connection.select_all(sql, nil, [[nil, @start_at], [nil, @end_at], [nil, params[:domain]]])

    rows.map { |row| { date: row['period'], value: row['value'].to_s } }
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
