# frozen_string_literal: true

class Api::V1::Instances::ActivityController < Api::V1::Instances::BaseController
  before_action :require_enabled_api!

  WEEKS_OF_ACTIVITY = 12

  def show
    cache_even_if_authenticated!
    render_with_cache json: :activity, expires_in: 1.day
  end

  private

  def activity
    activity_weeks.map do |weeks_ago|
      activity_json(*week_edge_days(weeks_ago))
    end
  end

  def activity_json(start_of_week, end_of_week)
    {
      week: start_of_week.to_i.to_s,
      statuses: statuses_tracker.sum(start_of_week, end_of_week).to_s,
      logins: logins_tracker.sum(start_of_week, end_of_week).to_s,
      registrations: registrations_tracker.sum(start_of_week, end_of_week).to_s,
    }
  end

  def activity_weeks
    0...WEEKS_OF_ACTIVITY
  end

  def week_edge_days(num)
    [num.weeks.ago, num.weeks.ago + 6.days]
  end

  def statuses_tracker
    ActivityTracker.new('activity:statuses:local', :basic)
  end

  def logins_tracker
    ActivityTracker.new('activity:logins', :unique)
  end

  def registrations_tracker
    ActivityTracker.new('activity:accounts:local', :basic)
  end

  def require_enabled_api!
    head 404 unless Setting.activity_api_enabled && !limited_federation_mode?
  end
end
