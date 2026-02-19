# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    include Redisable

    def index
      authorize :dashboard, :index?

      @pending_appeals_count = Appeal.pending.async_count
      @pending_reports_count = Report.unresolved.async_count
      @pending_tags_count    = pending_tags.async_count
      @pending_users_count   = User.pending.async_count
      @system_checks         = Admin::SystemCheck.perform(current_user)
      @time_period           = (29.days.ago.to_date...Time.now.utc.to_date)
    end

    private

    def pending_tags
      ::Trends::TagFilter.new(status: :pending_review).results
    end
  end
end
