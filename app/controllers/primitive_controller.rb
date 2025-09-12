# frozen_string_literal: true

class PrimitiveController < ActionController::Base # rubocop:disable Rails/ApplicationController
  content_security_policy(false)
end
