# frozen_string_literal: true

module Api::ErrorHandling
  extend ActiveSupport::Concern

  include ActionController::RequestId

  SENSITIVE_PATTERNS = [
    %r{\/([a-zA-Z]:\/)?Users\/[^\/]+},
    %r{\/home\/[^\/]+},
    %r{\/root},
    %r{[a-zA-Z]:\\Users\\[^\\]+},
    %r{[a-zA-Z]:\\home\\[^\\]+},
  ].freeze

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
      log_sanitized_error(e, level: :warn)
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

    rescue_from JSON::ParserError, Psych::SyntaxError do |e|
      log_sanitized_error(e)
      render json: { error: 'Invalid JSON data' }, status: 422
    end

    rescue_from Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError do |e|
      log_sanitized_error(e)
      render json: { error: 'Invalid character encoding' }, status: 422
    end

    rescue_from RangeError do |e|
      log_sanitized_error(e)
      render json: { error: 'Value out of range' }, status: 422
    end
  end

  private

  def log_sanitized_error(exception, level: :error)
    error_id = request_id || SecureRandom.uuid
    sanitized_class = exception.class.to_s
    sanitized_message = sanitize_error_message(exception.message)

    Rails.logger.send(level) do
      "[#{error_id}] #{sanitized_class}: #{sanitized_message}"
    end

    Rails.logger.debug do
      sanitized_backtrace = sanitize_backtrace(exception.backtrace)
      "[#{error_id}] Backtrace: #{sanitized_backtrace.first(10).join("\n")}" if sanitized_backtrace.present?
    end
  end

  def sanitize_error_message(message)
    return message.to_s if message.blank?

    sanitized = message.to_s.dup

    SENSITIVE_PATTERNS.each do |pattern|
      sanitized.gsub!(pattern, '[REDACTED]')
    end

    sanitized
  end

  def sanitize_backtrace(backtrace)
    return [] if backtrace.blank?

    backtrace.map do |line|
      sanitized = line.dup

      SENSITIVE_PATTERNS.each do |pattern|
        sanitized.gsub!(pattern, '[REDACTED]')
      end

      sanitized
    end
  end
end
