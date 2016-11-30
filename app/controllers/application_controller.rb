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
  before_action :set_user_activity

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

  def require_admin!
    redirect_to root_path unless current_user&.admin?
  end

  def set_user_activity
    current_user.touch(:current_sign_in_at) if !current_user.nil? && (current_user.current_sign_in_at.nil? || current_user.current_sign_in_at < 24.hours.ago)
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

  def cache_collection(raw, klass)
    return raw unless klass.respond_to?(:with_includes)

    uncached_ids           = []
    cached_keys_with_value = Rails.cache.read_multi(*raw.map(&:cache_key))

    raw.each do |item|
      uncached_ids << item.id unless cached_keys_with_value.key?(item.cache_key)
    end

    unless uncached_ids.empty?
      uncached = klass.where(id: uncached_ids).with_includes.map { |item| [item.id, item] }.to_h

      uncached.values.each do |item|
        Rails.cache.write(item.cache_key, item)
      end
    end

    raw.map { |item| cached_keys_with_value[item.cache_key] || uncached[item.id] }.compact
  end
end
