# frozen_string_literal: true

module Mastodon
  module EmailConfigurationHelper
    module_function

    # Convert smtp settings from environment variables (or defaults in
    # `config/email.yml`) into the format that `ActionMailer` understands
    def convert_smtp_settings(config)
      enable_starttls = nil

      case config[:enable_starttls]
      when 'always'
        enable_starttls = :always
      when 'never', 'false'
        enable_starttls = false
      when 'auto'
        enable_starttls = :auto
      else
        enable_starttls = config[:enable_starttls_auto] ? :auto : false unless config[:tls] || config[:ssl]
      end

      authentication = config[:authentication] == 'none' ? nil : (config[:authentication] || 'plain')

      config.without(:enable_starttls_auto).merge(
        authentication:,
        enable_starttls:
      )
    end
  end
end
