Rails.application.configure do
  config.x.http_client_proxy = {}
  if ENV['http_proxy'].present?
    proxy = URI.parse(ENV['http_proxy'])
    raise "Unsupported proxy type: #{proxy.scheme}" unless %w(http https).include? proxy.scheme
    raise "No proxy host" unless proxy.host

    host = proxy.host
    host = host[1...-1] if host[0] == '[' #for IPv6 address
    config.x.http_client_proxy[:proxy] = { proxy_address: host, proxy_port: proxy.port, proxy_username: proxy.user, proxy_password: proxy.password }.compact
  end

  config.x.access_to_hidden_service = ENV['ALLOW_ACCESS_TO_HIDDEN_SERVICE'] == 'true'
  config.x.hidden_service_via_transparent_proxy = ENV['HIDDEN_SERVICE_VIA_TRANSPARENT_PROXY'] == 'true'
end

module Goldfinger
  def self.finger(uri, opts = {})
    to_hidden = /\.(onion|i2p)(:\d+)?$/.match(uri)
    raise Mastodon::HostValidationError, 'Instance does not support hidden service connections' if !Rails.configuration.x.access_to_hidden_service && to_hidden
    opts = { ssl: !to_hidden, headers: {} }.merge(Rails.configuration.x.http_client_proxy).merge(opts)
    opts[:headers]['User-Agent'] ||= Mastodon::Version.user_agent
    Goldfinger::Client.new(uri, opts).finger
  end
end
