# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    include Redisable

    def index
      authorize :dashboard, :index?

      @dashboard = Admin::DashboardPresenter.new
      @system_checks = Admin::SystemCheck.perform(current_user)
      @time_period = (29.days.ago.to_date...Time.now.utc.to_date)
    end
  end
end
