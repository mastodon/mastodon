# frozen_string_literal: true

class CacheBuster
  def initialize(options = {})
    @secret_header = options[:secret_header] || 'Secret-Header'
    @secret        = options[:secret] || 'True'
  end

  def bust(url)
    site = Addressable::URI.parse(url).normalized_site

    request_pool.with(site) do |http_client|
      build_request(url, http_client).perform
    end
  end

  private

  def request_pool
    RequestPool.current
  end

  def build_request(url, http_client)
    Request.new(:get, url, http_client: http_client).tap do |request|
      request.add_headers(@secret_header => @secret)
    end
  end
end
