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
    MediaAttachment.where(account: Account.where(domain: params[:domain])).sum('file_file_size + thumbnail_file_size')
  end

  def perform_previous_total_query
    nil
  end

  def perform_data_query
    sql = <<-SQL.squish
      SELECT axis.*, (
        WITH new_media_attachments AS (
          SELECT media_attachments.file_file_size + media_attachments.thumbnail_file_size AS size
          FROM media_attachments
          INNER JOIN accounts ON accounts.id = media_attachments.account_id
          WHERE date_trunc('day', media_attachments.created_at)::date = axis.period
            AND accounts.domain = $3::text
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
    @params.permit(:domain)
  end
end
