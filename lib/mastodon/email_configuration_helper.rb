# frozen_string_literal: true

module Mastodon
  module EmailConfigurationHelper
    module_function

    # Convert smtp settings from environment variables (or defaults in
    # `config/email.yml`) into the format that `ActionMailer` understands
    def smtp_settings(config)
      enable_starttls = nil
      enable_starttls_auto = nil

      case config[:enable_starttls]
      when 'always'
        enable_starttls = true
      when 'never'
        enable_starttls = false
      when 'auto'
        enable_starttls_auto = true
      else
        enable_starttls_auto = config[:enable_starttls_auto] != 'false'
      end

      authentication = config[:authentication] == 'none' ? nil : (config[:authentication] || 'plain')

      config.merge(
        authentication:,
        enable_starttls:,
        enable_starttls_auto:
      )
    end
  end
end
