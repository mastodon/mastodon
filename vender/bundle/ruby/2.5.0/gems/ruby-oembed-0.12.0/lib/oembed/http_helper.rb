require 'openssl'

module OEmbed
  module HttpHelper

    private

    # Given a URI, make an HTTP request
    #
    # The options Hash recognizes the following keys:
    # :timeout:: specifies the timeout (in seconds) for the http request.
    # :max_redirects:: the number of times this request will follow 3XX redirects before throwing an error. Default: 4
    def http_get(uri, options = {})
      found = false
      remaining_redirects = options[:max_redirects] ? options[:max_redirects].to_i : 4
      until found
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.read_timeout = http.open_timeout = options[:timeout] if options[:timeout]

        methods = if RUBY_VERSION < "2.2"
            %w{scheme userinfo host port registry}
        else
            %w{scheme userinfo host port}
        end
        methods.each { |method| uri.send("#{method}=", nil) }
        req = Net::HTTP::Get.new(uri.to_s)
        req['User-Agent'] = "Mozilla/5.0 (compatible; ruby-oembed/#{OEmbed::VERSION})"
        res = http.request(req)

        if remaining_redirects == 0
          found = true
        elsif res.is_a?(Net::HTTPRedirection) && res.header['location']
          uri = URI.parse(res.header['location'])
          remaining_redirects -= 1
        else
          found = true
        end
      end

      case res
      when Net::HTTPNotImplemented
        raise OEmbed::UnknownFormat
      when Net::HTTPNotFound
        raise OEmbed::NotFound, uri
      when Net::HTTPSuccess
        res.body
      else
        raise OEmbed::UnknownResponse, res && res.respond_to?(:code) ? res.code : 'Error'
      end
    rescue StandardError
      # Convert known errors into OEmbed::UnknownResponse for easy catching
      # up the line. This is important if given a URL that doesn't support
      # OEmbed. The following are known errors:
      # * Net::* errors like Net::HTTPBadResponse
      # * JSON::JSONError errors like JSON::ParserError
      if defined?(::JSON) && $!.is_a?(::JSON::JSONError) || $!.class.to_s =~ /\ANet::/
        raise OEmbed::UnknownResponse, res && res.respond_to?(:code) ? res.code : 'Error'
      else
        raise $!
      end
    end

  end
end
