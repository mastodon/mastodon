# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

require 'mcaptcha/configuration'
require 'mcaptcha/helpers'
require 'mcaptcha/adapters/controller_methods'
require 'mcaptcha/adapters/view_methods'
require 'mcaptcha/railtie'

module Mcaptcha
  DEFAULT_TIMEOUT = 3
  RESPONSE_LIMIT = 32_767

  class McaptchaError < StandardError
  end

  class VerifyError < HcaptchaError
  end

  # Gives access to the current Configuration.
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Allows easy setting of multiple configuration options. See Configuration
  # for all available options.
  #--
  # The temp assignment is only used to get a nicer rdoc. Feel free to remove
  # this hack.
  #++
  def self.configure
    config = configuration
    yield(config)
  end

  def self.with_configuration(config)
    original_config = {}

    config.each do |key, value|
      original_config[key] = configuration.send(key)
      configuration.send(:"#{key}=", value)
    end

    yield if block_given?
  ensure
    original_config.each { |key, value| configuration.send(:"#{key}=", value) }
  end

  def self.skip_env?(env)
    configuration.skip_verify_env.include?(env || configuration.default_env)
  end

  def self.invalid_response?(resp)
    resp.empty? || resp.length > RESPONSE_LIMIT
  end

  def self.verify_via_api_call(response, options)
    secret_key = options.fetch(:secret_key) { configuration.secret_key! }
    verify_hash = { 'secret' => secret_key, 'response' => response }
    verify_hash['remoteip'] = options[:remote_ip] if options.key?(:remote_ip)

    reply = api_verification(verify_hash, timeout: options[:timeout])
    reply['success'].to_s == 'true' &&
      hostname_valid?(reply['hostname'], options[:hostname]) &&
      action_valid?(reply['action'], options[:action]) &&
      score_above_threshold?(reply['score'], options[:minimum_score])
  end

  def self.hostname_valid?(hostname, validation)
    validation ||= configuration.hostname

    case validation
    when nil, FalseClass then true
    when String then validation == hostname
    else validation.call(hostname)
    end
  end

  def self.action_valid?(action, expected_action)
    case expected_action
    when nil, FalseClass then true
    else action == expected_action
    end
  end

  # Returns true iff score is greater or equal to (>=) minimum_score, or if no minimum_score was specified
  def self.score_above_threshold?(score, minimum_score)
    return true if minimum_score.nil?
    return false if score.nil?

    case minimum_score
    when nil, FalseClass then true
    else score >= minimum_score
    end
  end

  def self.api_verification(verify_hash, timeout: DEFAULT_TIMEOUT)
    http = if configuration.proxy
             proxy_server = URI.parse(configuration.proxy)
             Net::HTTP::Proxy(proxy_server.host, proxy_server.port, proxy_server.user, proxy_server.password)
           else
             Net::HTTP
           end
    query = URI.encode_www_form(verify_hash)
    uri = URI.parse("#{configuration.verify_url}?#{query}")
    http_instance = http.new(uri.host, uri.port)
    http_instance.read_timeout = http_instance.open_timeout = timeout
    http_instance.use_ssl = true if uri.port == 443
    request = Net::HTTP::Get.new(uri.request_uri)
    JSON.parse(http_instance.request(request).body)
  end
end
