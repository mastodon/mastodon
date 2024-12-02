# frozen_string_literal: true

class HealthController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def show
    render plain: 'OK'
  end
end
