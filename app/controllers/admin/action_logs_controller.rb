# frozen_string_literal: true

module Admin
  class ActionLogsController < BaseController
    before_action :set_action_logs

    def index
      authorize :audit_log, :index?
      @auditable_accounts = Account.auditable.select(:id, :username).order(username: :asc)
    end

    private

    def set_action_logs
      @action_logs = Admin::ActionLogFilter.new(filter_params).results.page(params[:page])
    end

    def filter_params
      params.slice(:page, *Admin::ActionLogFilter::KEYS).permit(:page, *Admin::ActionLogFilter::KEYS)
    end
  end
end
