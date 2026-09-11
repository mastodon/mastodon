# frozen_string_literal: true

module ErrorResponses
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_content
    rescue_from ActionController::ParameterMissing, Paperclip::AdapterRegistry::NoHandlerError, with: :bad_request
    rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::UnknownFormat, with: :not_acceptable
    rescue_from Mastodon::NotPermittedError, with: :forbidden
    rescue_from Mastodon::RaceConditionError, Stoplight::Error::RedLight, ActiveRecord::SerializationFailure, with: :service_unavailable
    rescue_from Mastodon::RateLimitExceededError, with: :too_many_requests
    rescue_from(*Mastodon::HTTP_CONNECTION_ERRORS, with: :internal_server_error)

    rescue_from Seahorse::Client::NetworkingError do |e|
      Rails.logger.warn "Storage server error: #{e}"
      service_unavailable
    end
  end

  protected

  def bad_request
    respond_with_error(400)
  end

  def forbidden
    respond_with_error(403)
  end

  def gone
    respond_with_error(410)
  end

  def internal_server_error
    respond_with_error(500)
  end

  def not_acceptable
    respond_with_error(406)
  end

  def not_found
    respond_with_error(404)
  end

  def service_unavailable
    respond_with_error(503)
  end

  def too_many_requests
    respond_with_error(429)
  end

  def unprocessable_content
    respond_with_error(422)
  end

  private

  def respond_with_error(code)
    respond_to do |format|
      format.any  { render "errors/#{code}", layout: 'error', formats: [:html], status: code }
      format.json { render json: { error: Rack::Utils::HTTP_STATUS_CODES[code] }, status: code }
    end
  end
end
