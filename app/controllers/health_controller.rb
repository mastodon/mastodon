class HealthController < ActionController::Base
  def show
    render plain: 'OK'
  end
end
