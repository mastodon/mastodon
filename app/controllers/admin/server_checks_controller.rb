# frozen_string_literal: true

module Admin
  class ServerChecksController < BaseController
    def index
      authorize [:admin, :server_check], :index?

      @checks = Admin::ServerCheck.checks_for(current_user).group_by(&:category)
    end
  end
end
