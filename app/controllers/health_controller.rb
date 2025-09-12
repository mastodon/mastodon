# frozen_string_literal: true

class HealthController < PrimitiveController
  def show
    render plain: 'OK'
  end
end
