# frozen_string_literal: true

unless Rails.application.config.action_dispatch.trusted_proxies.nil?
  # Rack is configured with a default collection of trusted proxies
  # If Rails has been configured to use a specific list, configure
  # Rack to use this Proc, which enforces the Rails-configured list.
  Rack::Request.ip_filter = ->(ip) { Rails.application.config.action_dispatch.trusted_proxies.include?(ip) }
end
