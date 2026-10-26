# frozen_string_literal: true

module Admin
  class IgnoredServerChecksController < BaseController
    def create
      authorize check, :ignore?
      check.update_attribute(:ignored, true)

      redirect_to admin_server_checks_path
    end

    def destroy
      authorize check, :restore?
      check.update_attribute(:ignored, false)

      redirect_to admin_server_checks_path
    end

    private

    def check
      @check ||= Admin::ServerCheck.find_or_initialize_by(key: params[:key])
    end
  end
end
