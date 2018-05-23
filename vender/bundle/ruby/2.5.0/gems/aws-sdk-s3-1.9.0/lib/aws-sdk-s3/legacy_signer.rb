require 'set'
require 'time'
require 'openssl'
require 'cgi'
require 'webrick/httputils'
require 'aws-sdk-core/query'

module Aws
  module S3
    # @api private
    class LegacySigner

      SIGNED_QUERYSTRING_PARAMS = Set.new(%w(

        acl delete cors lifecycle location logging notification partNumber
        policy requestPayment restore tagging torrent uploadId uploads
        versionId versioning versions website replication requestPayment
        accelerate

        response-content-type response-content-language
        response-expires response-cache-control
        response-content-disposition response-content-encoding

      ))

      def self.sign(context)
        new(
          context.config.credentials,
          context.params,
          context.config.force_path_style
        ).sign(context.http_request)
      end

      # @param [CredentialProvider] credentials
      def initialize(credentials, params, force_path_style)
        @credentials = credentials.credentials
        @params = Query::ParamList.new
        params.each_pair do |param_name, param_value|
          @params.set(param_name, param_value)
        end
        @force_path_style = force_path_style
      end

      attr_reader :credentials, :params

      def sign(request)
        if token = credentials.session_token
          request.headers["X-Amz-Security-Token"] = token
        end
        request.headers['Authorization'] = authorization(request)
      end

      def authorization(request)
        "AWS #{credentials.access_key_id}:#{signature(request)}"
      end

      def signature(request)
        string_to_sign = string_to_sign(request)
        signature = digest(credentials.secret_access_key, string_to_sign)
        uri_escape(signature)
      end

      def digest(secret, string_to_sign)
        Base64.encode64(hmac(secret, string_to_sign)).strip
      end

      def hmac(key, value)
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), key, value)
      end

      # From the S3 developer guide:
      #
      #     StringToSign =
      #       HTTP-Verb ` "\n" `
      #       content-md5 ` "\n" `
      #       content-type ` "\n" `
      #       date ` "\n" `
      #       CanonicalizedAmzHeaders + CanonicalizedResource;
      #
      def string_to_sign(request)
        [
          request.http_method,
          request.headers.values_at('Content-Md5', 'Content-Type').join("\n"),
          signing_string_date(request),
          canonicalized_headers(request),
          canonicalized_resource(request.endpoint),
        ].flatten.compact.join("\n")
      end

      def signing_string_date(request)
        # if a date is provided via x-amz-date then we should omit the
        # Date header from the signing string (should appear as a blank line)
        if request.headers.detect{|k,v| k.to_s =~ /^x-amz-date$/i }
          ''
        else
          request.headers['Date'] = Time.now.httpdate
        end
      end

      # CanonicalizedAmzHeaders
      #
      # See the developer guide for more information on how this element
      # is generated.
      #
      def canonicalized_headers(request)
        x_amz = request.headers.select{|k, v| k =~ /^x-amz-/i }
        x_amz = x_amz.collect{|k, v| [k.downcase, v] }
        x_amz = x_amz.sort_by{|k, v| k }
        x_amz = x_amz.collect{|k, v| "#{k}:#{v.to_s.strip}" }.join("\n")
        x_amz == '' ? nil : x_amz
      end

      # From the S3 developer guide
      #
      #     CanonicalizedResource =
      #       [ "/" ` Bucket ] `
      #       <HTTP-Request-URI, protocol name up to the querystring> +
      #       [ sub-resource, if present. e.g. "?acl", "?location",
      #       "?logging", or "?torrent"];
      #
      # @api private
      def canonicalized_resource(endpoint)

        parts = []

        # virtual hosted-style requests require the hostname to appear
        # in the canonicalized resource prefixed by a forward slash.
        if bucket = params[:bucket]
          bucket = bucket.value
          ssl = endpoint.scheme == 'https'
          if Plugins::BucketDns.dns_compatible?(bucket, ssl) && !@force_path_style
            parts << "/#{bucket}"
          end
        end

        # append the path name (no querystring)
        parts << endpoint.path

        # lastly any sub resource querystring params need to be appened
        # in lexigraphical ordered joined by '&' and prefixed by '?'
        params = signed_querystring_params(endpoint)

        unless params.empty?
          parts << '?'
          parts << params.sort.collect{|p| p.to_s }.join('&')
        end

        parts.join
      end

      def signed_querystring_params(endpoint)
        endpoint.query.to_s.split('&').select do |p|
          SIGNED_QUERYSTRING_PARAMS.include?(p.split('=')[0])
        end.map { |p| CGI.unescape(p) }
      end

      def uri_escape(s)

        #URI.escape(s)

        # URI.escape is deprecated, replacing it with escape from webrick
        # to squelch the massive number of warnings generated from Ruby.
        # The following script was used to determine the differences
        # between the various escape methods available. The webrick
        # escape only had two differences and it is available in the
        # standard lib.
        #
        #     (0..255).each {|c|
        #       s = [c].pack("C")
        #       e = [
        #         CGI.escape(s),
        #         ERB::Util.url_encode(s),
        #         URI.encode_www_form_component(s),
        #         WEBrick::HTTPUtils.escape_form(s),
        #         WEBrick::HTTPUtils.escape(s),
        #         URI.escape(s),
        #       ]
        #       next if e.uniq.length == 1
        #       puts("%5s %5s %5s %5s %5s %5s %5s" % ([s.inspect] + e))
        #     }
        #
        WEBrick::HTTPUtils.escape(s).gsub('%5B', '[').gsub('%5D', ']')
      end

    end
  end
end
