# frozen_string_literal: true

class Api::V1::Instances::ActivityController < Api::BaseController
  before_action :require_enabled_api!

  skip_before_action :set_cache_headers
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  respond_to :json

  def show
    expires_in 1.day, public: true
    render_with_cache json: :activity, expires_in: 1.day
  end

  private

  def activity
    weeks = []

    12.times do |i|
      day     = i.weeks.ago.to_date
      week_id = day.cweek
      week    = Date.commercial(day.cwyear, week_id)

      weeks << {
        week: week.to_time.to_i.to_s,
        statuses: Redis.current.get("activity:statuses:local:#{week_id}") || '0',
        logins: Redis.current.pfcount("activity:logins:#{week_id}").to_s,
        registrations: Redis.current.get("activity:accounts:local:#{week_id}") || '0',
      }
    end

    weeks
  end

  def require_enabled_api!
    head 404 unless Setting.activity_api_enabled && !whitelist_mode?
  end
end
