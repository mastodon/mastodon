# frozen_string_literal: true

class Api::V1::Instances::ActivityController < Api::BaseController
  respond_to :json

  def show
    render_cached_json('api:v1:instances:activity:show', expires_in: 1.day) { activity }
  end

  private

  def activity
    weeks = []

    12.times do |i|
      week    = i.weeks.ago.to_date
      week_id = week.cweek

      weeks << {
        week: week.to_time.to_i.to_s,
        statuses: Redis.current.get("activity:statuses:local:#{week_id}"),
        logins: Redis.current.pfcount("activity:logins:#{week_id}"),
        registrations: Redis.current.get("activity:accounts:local:#{week_id}"),
      }
    end

    weeks
  end
end
