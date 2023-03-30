# frozen_string_literal: true

class Api::V1::Instances::ActivityController < Api::BaseController
  before_action :require_enabled_api!

  skip_before_action :set_cache_headers
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  def show
    expires_in 1.day, public: true
    render json: activity
  end

  private

  def activity
    statuses_tracker      = ActivityTracker.new('activity:statuses:local', :basic)
    logins_tracker        = ActivityTracker.new('activity:logins', :unique)
    registrations_tracker = ActivityTracker.new('activity:accounts:local', :basic)

    (0...12).map do |i|
      start_of_week = i.weeks.ago
      end_of_week   = start_of_week + 6.days

      {
        week: start_of_week.to_i.to_s,
        statuses: statuses_tracker.sum(start_of_week, end_of_week).to_s,
        logins: logins_tracker.sum(start_of_week, end_of_week).to_s,
        registrations: registrations_tracker.sum(start_of_week, end_of_week).to_s,
      }
    end
  end

  def require_enabled_api!
    head 404 unless Setting.activity_api_enabled && !whitelist_mode?
  end
end
