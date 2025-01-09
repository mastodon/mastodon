# frozen_string_literal: true

module Mcaptcha
  # This class enables detailed configuration of the mCaptcha services.
  #
  # By calling
  #
  #   Mcaptcha.configuration # => instance of Mcaptcha::Configuration
  #
  # or
  #   Mcaptcha.configure do |config|
  #     config # => instance of Mcaptcha::Configuration
  #   end
  #
  # you are able to perform configuration updates.
  #
  # Your are able to customize all attributes listed below. All values have
  # sensitive default and will very likely not need to be changed.
  #
  # Please note that the site and secret key for the mCaptcha API Access
  # have no useful default value. The keys may be set via the Shell enviroment
  # or using this configuration. Settings within this configuration always take
  # precedence.
  #
  # Setting the keys with this Configuration
  #
  #   Mcaptcha.configure do |config|
  #     config.site_key  = 'your-site-key-here'
  #     config.secret_key = 'your-secret-key-here'
  #   end
  #
  class Configuration
    DEFAULTS = {
      'server_url' => 'http://localhost:7000',
      'verify_url' => 'http://localhost:7000/api/v1/pow/siteverify',
    }.freeze

    attr_accessor :default_env, :skip_verify_env, :secret_key, :site_key, :proxy, :handle_timeouts_gracefully, :hostname
    attr_writer :api_server_url, :verify_url

    def initialize # :nodoc:
      @default_env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || (Rails.env if defined? Rails.env)
      @skip_verify_env = %w(test cucumber)
      @handle_timeouts_gracefully = true

      @secret_key = ENV.fetch('MCAPTCHA_SECRET_KEY', nil)
      @site_key = ENV.fetch('MCAPTCHA_SITE_KEY', nil)
      @verify_url = nil
      @api_server_url = nil
    end

    def secret_key!
      secret_key || raise(McaptchaError, 'No secret key specified.')
    end

    def site_key!
      site_key || raise(McaptchaError, 'No site key specified.')
    end

    def api_server_url
      @api_server_url || DEFAULTS.fetch('server_url')
    end

    def verify_url
      @verify_url || DEFAULTS.fetch('verify_url')
    end
  end
end
