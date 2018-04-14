Rails.application.configure do
  config.x.http_client_proxy = {}
  ['HTTP_PROXY', 'http_proxy'].each do |name|
    next if ENV[name].blank?
    proxy = URI.parse(ENV[name])
    raise Mastodon::ValidationError, "Unsupported proxy type: #{proxy.scheme}" unless ["http", "https"].include? proxy.scheme
    raise Mastodon::ValidationError, "No proxy host" unless proxy.host

    host = proxy.host
    host = host[1...-1] if host[0] == '[' #for IPv6 address
    config.x.http_client_proxy[:proxy] = { proxy_address: host, proxy_port: proxy.port, proxy_username: proxy.user, proxy_password: proxy.password }.compact
    break
  end

  config.x.access_to_darknet = ENV['ALLOW_ACCESS_TO_DARKNET'] == 'true'
  config.x.darknet_via_transparent_proxy = ENV['DARKNET_VIA_TRANSPARENT_PROXY'] == 'true'
end

module Goldfinger
  def self.finger(uri, opts = {})
    to_darknet = /\.(onion|i2p)(:\d+)?$/.match(uri)
    raise Mastodon::HostValidationError, 'blocked access to darknet' if !Rails.configuration.x.access_to_darknet && to_darknet
    opts = opts.merge(Rails.configuration.x.http_client_proxy).merge(ssl: !to_darknet)
    Goldfinger::Client.new(uri, opts).finger
  end
end
