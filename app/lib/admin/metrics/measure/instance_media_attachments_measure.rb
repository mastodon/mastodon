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

  def data_source_query
    MediaAttachment
      .select('COALESCE(media_attachments.file_file_size, 0) + COALESCE(media_attachments.thumbnail_file_size, 0) AS size')
      .joins(:account)
      .where(account_domain_sql(params[:include_subdomains]))
      .where(daily_period(:media_attachments))
  end

  def select_target
    <<~SQL.squish
      COALESCE(SUM(size), 0)
    SQL
  end

  def params
    @params.permit(:domain, :include_subdomains)
  end
end
