# frozen_string_literal: true

class ProviderDiscovery < OEmbed::ProviderDiscovery
  USER_AGENT = "#{HTTP::Request::USER_AGENT} (Mastodon/#{Mastodon::VERSION}; +http://#{Rails.configuration.x.local_domain}/)"

  class << self
    def discover_provider(url, options = {})
      res    = http_client.get(url)
      format = options[:format]

      raise OEmbed::NotFound, url if res.code != 200 || res.mime_type != 'text/html'

      html = Nokogiri::HTML(res.to_s)

      if format.nil? || format == :json
        provider_endpoint = html.at_xpath('//link[@type="application/json+oembed"]')['href']
        format ||= :json
      end

      if format.nil? || format == :xml
        provider_endpoint = html.at_xpath('//link[@type="application/xml+oembed"]')['href']
        format ||= :xml
      end

      provider_endpoint = Addressable::URI.parse(provider_endpoint)
      provider_endpoint.query = nil
      provider_endpoint = provider_endpoint.to_s

      raise OEmbed::NotFound, url if provider_endpoint.blank?

      OEmbed::Provider.new(provider_endpoint, format || OEmbed::Formatter.default)
    end

    def http_client
      HTTP.headers(user_agent: USER_AGENT).timeout(:per_operation, write: 10, connect: 10, read: 10).follow
    end
  end
end
