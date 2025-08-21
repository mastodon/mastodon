# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_web_app_headers
  end

  private

  def set_web_app_headers
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
  end

  def render_bad_request
    head 400
  end

  def some_action
    if some_condition
      # Do something
    end
    # Redundant else clause removed
  end
end
