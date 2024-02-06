# frozen_string_literal: true

class CustomCssController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def show
    expires_in 3.minutes, public: true
    render content_type: 'text/css'
  end
end
