class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if: "Rails.env.production? && ENV['LOCAL_HTTPS'] == 'true'"

  # Profiling
  before_action do
    if (current_user && current_user.admin?) || Rails.env.development?
      Rack::MiniProfiler.authorize_request
    end
  end

  protected

  def current_account
    current_user.try(:account)
  end
end
