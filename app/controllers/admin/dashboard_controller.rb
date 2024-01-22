# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    include Redisable

    def index
      authorize :dashboard, :index?

      @system_checks         = Admin::SystemCheck.perform(current_user)
      @time_period           = (29.days.ago.to_date...Time.now.utc.to_date)
      @pending_users_count   = User.pending.count
      @pending_reports_count = Report.unresolved.count
      @pending_tags_count    = Tag.pending_review.count
      @pending_appeals_count = Appeal.pending.count
    end
  end
end
