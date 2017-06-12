# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if: :https_enabled?

  include Localized
  include UserTrackingConcern

  helper_method :current_account
  helper_method :single_user_mode?

  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity

  before_action :store_current_location, except: :raise_not_found, unless: :devise_controller?
  before_action :check_suspension, if: :user_signed_in?

  def raise_not_found
    raise ActionController::RoutingError, "No route matches #{params[:unmatched_route]}"
  end

  private

  def https_enabled?
    Rails.env.production? && ENV['LOCAL_HTTPS'] == 'true'
  end

  def store_current_location
    store_location_for(:user, request.url)
  end

  def require_admin!
    redirect_to root_path unless current_user&.admin?
  end

  def check_suspension
    forbidden if current_user.account.suspended?
  end

  protected

  def forbidden
    respond_with_error(403)
  end

  def not_found
    respond_with_error(404)
  end

  def gone
    respond_with_error(410)
  end

  def unprocessable_entity
    respond_with_error(422)
  end

  def single_user_mode?
    @single_user_mode ||= Rails.configuration.x.single_user_mode && Account.exists?
  end

  def current_account
    @current_account ||= current_user.try(:account)
  end

  def cache_collection(raw, klass)
    return raw unless klass.respond_to?(:with_includes)

    raw                    = raw.cache_ids.to_a if raw.is_a?(ActiveRecord::Relation)
    uncached_ids           = []
    cached_keys_with_value = Rails.cache.read_multi(*raw.map(&:cache_key))

    raw.each do |item|
      uncached_ids << item.id unless cached_keys_with_value.key?(item.cache_key)
    end

    klass.reload_stale_associations!(cached_keys_with_value.values) if klass.respond_to?(:reload_stale_associations!)

    unless uncached_ids.empty?
      uncached = klass.where(id: uncached_ids).with_includes.map { |item| [item.id, item] }.to_h

      uncached.values.each do |item|
        Rails.cache.write(item.cache_key, item)
      end
    end

    raw.map { |item| cached_keys_with_value[item.cache_key] || uncached[item.id] }.compact
  end

  def respond_with_error(code)
    respond_to do |format|
      format.any  { head code }
      format.html do
        set_locale
        render "errors/#{code}", layout: 'error', status: code
      end
    end
  end
end
