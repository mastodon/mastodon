# frozen_string_literal: true

module Admin
  class SoftwareUpdatesController < BaseController
    before_action :check_enabled!

    def index
      authorize :software_update, :index?
      @software_updates = SoftwareUpdate.by_version.filter(&:pending?)
    end

    private

    def check_enabled!
      not_found unless SoftwareUpdate.check_enabled?
    end
  end
end
