# frozen_string_literal: true

module HttpHelper
  def http_client(options = {})
    timeout = { write: 10, connect: 10, read: 10 }.merge(options)

    HTTP.headers(user_agent: user_agent)
        .timeout(:per_operation, timeout)
        .follow
  end

  private

  def user_agent
    @user_agent ||= "#{HTTP::Request::USER_AGENT} (Mastodon/#{Mastodon::Version}; +http://#{Rails.configuration.x.local_domain}/)"
  end
end
