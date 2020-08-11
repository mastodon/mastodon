# frozen_string_literal: true

# Monkey-patch on monkey-patch.
# Because it conflicts with the request.rb patch.
class HTTP::Timeout::PerOperationOriginal < HTTP::Timeout::PerOperation
  def connect(socket_class, host, port, nodelay = false)
    ::Timeout.timeout(@connect_timeout, HTTP::TimeoutError) do
      @socket = socket_class.open(host, port)
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) if nodelay
    end
  end
end

module WebfingerHelper
  def webfinger!(uri)
    hidden_service_uri = /\.(onion|i2p)(:\d+)?$/.match(uri)

    raise Mastodon::HostValidationError, 'Instance does not support hidden service connections' if !Rails.configuration.x.access_to_hidden_service && hidden_service_uri

    opts = {
      ssl: !hidden_service_uri,

      headers: {
        'User-Agent': Mastodon::Version.user_agent,
      },

      timeout_class: HTTP::Timeout::PerOperationOriginal,

      timeout_options: {
        write_timeout: 10,
        connect_timeout: 5,
        read_timeout: 10,
      },
    }

    Goldfinger::Client.new(uri, opts.merge(Rails.configuration.x.http_client_proxy)).finger
  end
end
