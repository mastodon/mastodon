# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if: "Rails.env.production? && ENV['LOCAL_HTTPS'] == 'true'"

  helper_method :current_account

  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :store_current_location, except: :raise_not_found, unless: :devise_controller?
  before_action :set_locale
  before_action :check_rack_mini_profiler

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def set_locale
    I18n.locale = current_user.try(:locale) || I18n.default_locale
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end

  def check_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if current_user && current_user.admin?
  end

  protected

  def not_found
    respond_to do |format|
      format.any { head 404 }
    end
  end

  def gone
    respond_to do |format|
      format.any { head 410 }
    end
  end

  def current_account
    @current_account ||= current_user.try(:account)
  end
end
