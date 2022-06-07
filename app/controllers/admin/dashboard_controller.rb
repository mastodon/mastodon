# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @system_checks         = Admin::SystemCheck.perform
      @time_period           = (29.days.ago.to_date...Time.now.utc.to_date)
      @pending_users_count   = User.pending.count
      @pending_reports_count = Report.unresolved.count
      @pending_tags_count    = Tag.pending_review.count
      @pending_appeals_count = Appeal.pending.count
    end

    private

    def redis_info
      @redis_info ||= begin
        if Redis.current.is_a?(Redis::Namespace)
          Redis.current.redis.info
        else
          Redis.current.info
        end
      end
    end
  end
end
