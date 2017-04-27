# frozen_string_literal: true

module HttpHelper
  USER_AGENT = "#{HTTP::Request::USER_AGENT} (Mastodon/#{Mastodon::Version}; +http://#{Rails.configuration.x.local_domain}/)"

  def http_client(options = {})
    timeout = { write: 10, connect: 10, read: 10 }.merge(options)

    HTTP.headers(user_agent: USER_AGENT)
        .timeout(:per_operation, timeout)
        .follow
  end
end
