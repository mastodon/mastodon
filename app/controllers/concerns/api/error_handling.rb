# frozen_string_literal: true

module Api::ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
      render json: { error: e.to_s }, status: 422
    end

    rescue_from ActiveRecord::RecordNotUnique do
      render json: { error: error_message(:record_not_unique) }, status: 422
    end

    rescue_from Date::Error do
      render json: { error: error_message(:invalid_date) }, status: 422
    end

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: error_message(:record_not_found) }, status: 404
    end

    rescue_from HTTP::Error, Mastodon::UnexpectedResponseError do
      render json: { error: error_message(:remote_data_fetch) }, status: 503
    end

    rescue_from OpenSSL::SSL::SSLError do
      render json: { error: error_message(:ssl_error) }, status: 503
    end

    rescue_from Mastodon::NotPermittedError do
      render json: { error: error_message(:not_permitted) }, status: 403
    end

    rescue_from Seahorse::Client::NetworkingError do |e|
      Rails.logger.warn "Storage server error: #{e}"
      render json: { error: error_message(:temporary_problem) }, status: 503
    end

    rescue_from Mastodon::RaceConditionError, Stoplight::Error::RedLight do
      render json: { error: error_message(:temporary_problem) }, status: 503
    end

    rescue_from Mastodon::RateLimitExceededError do
      render json: { error: I18n.t('errors.429') }, status: 429
    end

    rescue_from ActionController::ParameterMissing, Mastodon::InvalidParameterError do |e|
      render json: { error: e.to_s }, status: 400
    end
  end

  private

  def error_message(key)
    t("api.errors.#{key}")
  end
end
