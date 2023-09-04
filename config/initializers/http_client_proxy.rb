Rails.application.configure do
  config.x.http_client_proxy = {}

  if ENV['http_proxy'].present?
    proxy = URI.parse(ENV['http_proxy'])

    raise "Unsupported proxy type: #{proxy.scheme}" unless %w(http https).include? proxy.scheme
    raise "No proxy host" unless proxy.host

    host = proxy.host
    host = host[1...-1] if host[0] == '[' # for IPv6 address

    config.x.http_client_proxy[:proxy] = {
      proxy_address: host,
      proxy_port: proxy.port,
      proxy_username: proxy.user,
      proxy_password: proxy.password,
    }.compact
  end

  if ENV['http_hidden_proxy'].present?
    proxy = URI.parse(ENV['http_hidden_proxy'])

    raise "Unsupported proxy type: #{proxy.scheme}" unless %w(http https).include? proxy.scheme
    raise "No proxy host" unless proxy.host

    host = proxy.host
    host = host[1...-1] if host[0] == '[' # for IPv6 address

    config.x.http_client_hidden_proxy[:proxy] = {
      proxy_address: host,
      proxy_port: proxy.port,
      proxy_username: proxy.user,
      proxy_password: proxy.password,
    }.compact
  end

  config.x.access_to_hidden_service = ENV['ALLOW_ACCESS_TO_HIDDEN_SERVICE'] == 'true'
end
