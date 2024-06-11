# frozen_string_literal: true

class CacheBuster
  def initialize(options = {})
    ActiveSupport::Deprecation.warn('Default values for the cache buster secret header name and values will be removed in Mastodon 4.3. Please set them explicitely if you rely on those.') unless options[:http_method] || (options[:secret] && options[:secret_header])

    @secret_header = options[:secret_header] ||
                     (options[:http_method] ? nil : 'Secret-Header')
    @secret = options[:secret] ||
              (options[:http_method] ? nil : 'True')

    @http_method = options[:http_method] || 'GET'
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
    request = Request.new(@http_method.downcase.to_sym, url, http_client: http_client)
    request.add_headers(@secret_header => @secret) if @secret_header.present? && @secret && !@secret.empty?

    request
  end
end
