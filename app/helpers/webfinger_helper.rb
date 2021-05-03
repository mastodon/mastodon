# frozen_string_literal: true

module WebfingerHelper
  def webfinger!(uri)
    hidden_service_uri = /\.(onion|i2p)(:\d+)?$/.match(uri)

    raise Mastodon::HostValidationError, 'Instance does not support hidden service connections' if !Rails.configuration.x.access_to_hidden_service && hidden_service_uri

    opts = {
      ssl: !hidden_service_uri,

      headers: {
        'User-Agent': Mastodon::Version.user_agent,
      },
    }

    Goldfinger::Client.new(uri, opts.merge(Rails.configuration.x.http_client_proxy)).finger
  end
end
