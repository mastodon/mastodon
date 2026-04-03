# frozen_string_literal: true

class HealthController < Rails::HealthController
  content_security_policy false

  before_action :handle_default, if: -> { request.format.text? }

  private

  def handle_default
    render plain: 'OK'
  end
end
