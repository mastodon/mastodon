class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if: "Rails.env.production? && ENV['LOCAL_HTTPS'] == 'true'"

  helper_method :current_account

  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_filter :store_current_location, :unless => :devise_controller?

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  protected

  def not_found
    respond_to do |format|
      format.any { head 404 }
    end
  end

  def current_account
    current_user.try(:account)
  end
end
