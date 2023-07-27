# frozen_string_literal: true

class CacheBuster
  def initialize(options = {})
    @secret_header = options[:secret_header] || nil
    @secret        = options[:secret] || nil
    @http_method   = options[:http_method] || 'GET'
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
    request = Request.new(@http_method.to_sym, url, http_client: http_client)
    if @secret_header && !@secret_header.empty? && @secret && !@secret.empty?
      request.add_headers(@secret_header => @secret)
    end
  end
end
