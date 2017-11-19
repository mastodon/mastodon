# frozen_string_literal: true

module Admin
  class ActionLogsController < BaseController
    def index
      @action_logs = Admin::ActionLog.page(params[:page])
    end
  end
end
