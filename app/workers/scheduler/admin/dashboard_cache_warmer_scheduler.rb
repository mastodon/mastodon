# frozen_string_literal: true

class Scheduler::Admin::DashboardCacheWarmerScheduler
  include Sidekiq::Worker

  # The values in this file have to align with the values in app/views/admin/dashboard/index.html.haml
  # so that the generated cache keys are the same, otherwise cache warming will have no benefit

  MEASURES = %w(
    new_users
    active_users
    interactions
    opened_reports
    resolved_reports
  ).freeze

  DIMENSIONS = %w(
    sources
    languages
    servers
    software_versions
    space_usage
  ).freeze

  DIMENSION_LIMIT = 8

  TIME_PERIOD_DAYS = 29

  RETENTION_TIME_PERIOD_MONTHS = 6

  def perform
    @start_at = TIME_PERIOD_DAYS.days.ago.to_date
    @end_at = Time.now.utc.to_date
    @retention_start_at = @end_at - RETENTION_TIME_PERIOD_MONTHS.months
    @retention_end_at = @end_at

    warm_measures_cache!
    warm_dimensions_cache!
    warm_retention_cache!
  end

  private

  def warm_measures_cache!
    Admin::Metrics::Measure.retrieve(MEASURES, @start_at, @end_at, {}).each(&:perform_for_cache!)
  end

  def warm_dimensions_cache!
    Admin::Metrics::Dimension.retrieve(DIMENSIONS, @start_at, @end_at, DIMENSION_LIMIT, {}).each(&:perform_for_cache!)
  end

  def warm_retention_cache!
    Admin::Metrics::Retention.new(@retention_start_at, @retention_end_at, 'month').perform_for_cache!
  end
end
