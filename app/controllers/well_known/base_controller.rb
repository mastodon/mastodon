# frozen_string_literal: true

module WellKnown
  class BaseController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include RoutingHelper
  end
end
