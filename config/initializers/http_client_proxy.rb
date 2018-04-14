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
end

module Goldfinger
  def self.finger(uri, opts = {})
    opts = opts.merge(Rails.configuration.x.http_client_proxy)
    Goldfinger::Client.new(uri, opts).finger
  end
end
