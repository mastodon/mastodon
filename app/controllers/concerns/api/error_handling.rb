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

    rescue_from StandardError do |e|
      handle_api_error(e)
    end
  end

  private

  def handle_api_error(exception)
    error_id = request_id || SecureRandom.uuid
    sanitized_message = sanitize_error_message(exception.message)
    sanitized_backtrace = sanitize_backtrace(exception.backtrace)

    Rails.logger.error do
      "[#{error_id}] API Error: #{exception.class}: #{sanitized_message}"
    end

    Rails.logger.debug do
      "[#{error_id}] Backtrace: #{sanitized_backtrace.join("\n")}" if sanitized_backtrace.present?
    end

    if respond_to?(:doorkeeper_token, true) && doorkeeper_token
      Rails.logger.debug do
        "[#{error_id}] Token: #{doorkeeper_token.id}, Application: #{doorkeeper_token.application_id}"
      end
    end

    if respond_to?(:current_user, true) && current_user
      Rails.logger.debug do
        "[#{error_id}] User: #{current_user.id}, Account: #{current_user.account_id}"
      end
    end

    error_message = case exception
                    when JSON::ParserError, Psych::SyntaxError
                      'Invalid JSON data'
                    when Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
                      'Invalid character encoding'
                    when ArgumentError
                      if exception.message.include?('invalid byte sequence') || exception.message.include?('invalid UTF-8')
                        'Invalid character encoding'
                      else
                        'Invalid parameter'
                      end
                    when RangeError
                      'Value out of range'
                    when NoMethodError, NameError
                      Rails.logger.error "[#{error_id}] Unhandled code error: #{exception.class}: #{sanitized_message}"
                      'An unexpected error occurred'
                    else
                      'An unexpected error occurred'
                    end

    render json: { error: error_message }, status: 422
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
