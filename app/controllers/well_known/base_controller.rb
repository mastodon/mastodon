# frozen_string_literal: true

module WellKnown
  class BaseController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include RoutingHelper

    LONG_DURATION = 3.days
    NEAR_DURATION = 30.minutes
    SHORT_DURATION = 3.minutes
  end
end
