# frozen_string_literal: true

module Api::ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
      render json: { error: e.to_s }, status: 422
    end

    rescue_from ActiveRecord::RecordNotUnique do
      render json: { error: 'Duplicate record' }, status: 422
    end

    rescue_from Date::Error do
      render json: { error: 'Invalid date supplied' }, status: 422
    end

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: 'Record not found' }, status: 404
    end

    rescue_from(*Mastodon::HTTP_CONNECTION_ERRORS, Mastodon::UnexpectedResponseError) do
      render json: { error: 'Remote data could not be fetched' }, status: 503
    end

    rescue_from OpenSSL::SSL::SSLError do
      render json: { error: 'Remote SSL certificate could not be verified' }, status: 503
    end

    rescue_from Mastodon::NotPermittedError do
      render json: { error: 'This action is not allowed' }, status: 403
    end

    rescue_from Seahorse::Client::NetworkingError do |e|
      Rails.logger.warn "Storage server error: #{e}"
      render json: { error: 'There was a temporary problem serving your request, please try again' }, status: 503
    end

    rescue_from Mastodon::RaceConditionError, Stoplight::Error::RedLight do
      render json: { error: 'There was a temporary problem serving your request, please try again' }, status: 503
    end

    rescue_from Mastodon::RateLimitExceededError do
      render json: { error: I18n.t('errors.429') }, status: 429
    end

    rescue_from ActionController::ParameterMissing, Mastodon::InvalidParameterError do |e|
      render json: { error: e.to_s }, status: 400
    end
  end
end
