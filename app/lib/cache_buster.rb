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
    # this breaks because purge isn't a public method for http_client.public_send ->
    # NoMethodError: undefined method `purge' for #<HTTP::Client:0x0000000117a5e980
    request = Request.new(@http_method.downcase.to_sym, url, http_client: http_client)
    return unless @secret_header.present? && @secret && !@secret.empty?

    request.add_headers(@secret_header => @secret)
  end
end
