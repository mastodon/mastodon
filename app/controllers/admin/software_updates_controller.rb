# frozen_string_literal: true

module Admin
  class SoftwareUpdatesController < BaseController
    before_action :check_enabled!

    def index
      authorize :software_update, :index?
      @software_updates = SoftwareUpdate.all.sort_by(&:gem_version)
    end

    private

    def check_enabled!
      not_found if ENV['UPDATE_CHECK_URL'] == ''
    end
  end
end
