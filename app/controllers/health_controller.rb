# frozen_string_literal: true

class HealthController < ActionController::Base
  def show
    render plain: 'OK'
  end
end
