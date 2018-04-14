# frozen_string_literal: true

require "action_controller/railtie"

module Browser
  module ActionController
    extend ActiveSupport::Concern

    included do
      helper_method(:browser) if respond_to?(:helper_method)
    end

    private

    def browser
      @browser ||= Browser.new(
        request.headers["User-Agent"],
        accept_language: request.headers["Accept-Language"]
      )
    end
  end
end
