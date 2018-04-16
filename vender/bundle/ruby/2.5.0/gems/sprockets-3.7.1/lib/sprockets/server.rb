require 'time'
require 'rack/utils'

module Sprockets
  # `Server` is a concern mixed into `Environment` and
  # `CachedEnvironment` that provides a Rack compatible `call`
  # interface and url generation helpers.
  module Server
    # `call` implements the Rack 1.x specification which accepts an
    # `env` Hash and returns a three item tuple with the status code,
    # headers, and body.
    #
    # Mapping your environment at a url prefix will serve all assets
    # in the path.
    #
    #     map "/assets" do
    #       run Sprockets::Environment.new
    #     end
    #
    # A request for `"/assets/foo/bar.js"` will search your
    # environment for `"foo/bar.js"`.
    def call(env)
      start_time = Time.now.to_f
      time_elapsed = lambda { ((Time.now.to_f - start_time) * 1000).to_i }

      if !['GET', 'HEAD'].include?(env['REQUEST_METHOD'])
        return method_not_allowed_response
      end

      msg = "Served asset #{env['PATH_INFO']} -"

      # Extract the path from everything after the leading slash
      path = Rack::Utils.unescape(env['PATH_INFO'].to_s.sub(/^\//, ''))

      # Strip fingerprint
      if fingerprint = path_fingerprint(path)
        path = path.sub("-#{fingerprint}", '')
      end

      # URLs containing a `".."` are rejected for security reasons.
      if forbidden_request?(path)
        return forbidden_response(env)
      end

      # Look up the asset.
      options = {}
      options[:pipeline] = :self if body_only?(env)

      asset = find_asset(path, options)

      # 2.x/3.x compatibility hack. Just ignore fingerprints on ?body=1 requests.
      # 3.x/4.x prefers strong validation of fingerprint to body contents, but
      # 2.x just ignored it.
      if asset && parse_asset_uri(asset.uri)[1][:pipeline] == "self"
        fingerprint = nil
      end

      if fingerprint
        if_match = fingerprint
      elsif env['HTTP_IF_MATCH']
        if_match = env['HTTP_IF_MATCH'][/^"(\w+)"$/, 1]
      end

      if env['HTTP_IF_NONE_MATCH']
        if_none_match = env['HTTP_IF_NONE_MATCH'][/^"(\w+)"$/, 1]
      end

      if asset.nil?
        status = :not_found
      elsif fingerprint && asset.etag != fingerprint
        status = :not_found
      elsif if_match && asset.etag != if_match
        status = :precondition_failed
      elsif if_none_match && asset.etag == if_none_match
        status = :not_modified
      else
        status = :ok
      end

      case status
      when :ok
        logger.info "#{msg} 200 OK (#{time_elapsed.call}ms)"
        ok_response(asset, env)
      when :not_modified
        logger.info "#{msg} 304 Not Modified (#{time_elapsed.call}ms)"
        not_modified_response(env, if_none_match)
      when :not_found
        logger.info "#{msg} 404 Not Found (#{time_elapsed.call}ms)"
        not_found_response(env)
      when :precondition_failed
        logger.info "#{msg} 412 Precondition Failed (#{time_elapsed.call}ms)"
        precondition_failed_response(env)
      end
    rescue Exception => e
      logger.error "Error compiling asset #{path}:"
      logger.error "#{e.class.name}: #{e.message}"

      case File.extname(path)
      when ".js"
        # Re-throw JavaScript asset exceptions to the browser
        logger.info "#{msg} 500 Internal Server Error\n\n"
        return javascript_exception_response(e)
      when ".css"
        # Display CSS asset exceptions in the browser
        logger.info "#{msg} 500 Internal Server Error\n\n"
        return css_exception_response(e)
      else
        raise
      end
    end

    private
      def forbidden_request?(path)
        # Prevent access to files elsewhere on the file system
        #
        #     http://example.org/assets/../../../etc/passwd
        #
        path.include?("..") || absolute_path?(path)
      end

      def head_request?(env)
        env['REQUEST_METHOD'] == 'HEAD'
      end

      # Returns a 200 OK response tuple
      def ok_response(asset, env)
        if head_request?(env)
          [ 200, headers(env, asset, 0), [] ]
        else
          [ 200, headers(env, asset, asset.length), asset ]
        end
      end

      # Returns a 304 Not Modified response tuple
      def not_modified_response(env, etag)
        [ 304, cache_headers(env, etag), [] ]
      end

      # Returns a 403 Forbidden response tuple
      def forbidden_response(env)
        if head_request?(env)
          [ 403, { "Content-Type" => "text/plain", "Content-Length" => "0" }, [] ]
        else
          [ 403, { "Content-Type" => "text/plain", "Content-Length" => "9" }, [ "Forbidden" ] ]
        end
      end

      # Returns a 404 Not Found response tuple
      def not_found_response(env)
        if head_request?(env)
          [ 404, { "Content-Type" => "text/plain", "Content-Length" => "0", "X-Cascade" => "pass" }, [] ]
        else
          [ 404, { "Content-Type" => "text/plain", "Content-Length" => "9", "X-Cascade" => "pass" }, [ "Not found" ] ]
        end
      end

      def method_not_allowed_response
        [ 405, { "Content-Type" => "text/plain", "Content-Length" => "18" }, [ "Method Not Allowed" ] ]
      end

      def precondition_failed_response(env)
        if head_request?(env)
          [ 412, { "Content-Type" => "text/plain", "Content-Length" => "0", "X-Cascade" => "pass" }, [] ]
        else
          [ 412, { "Content-Type" => "text/plain", "Content-Length" => "19", "X-Cascade" => "pass" }, [ "Precondition Failed" ] ]
        end
      end

      # Returns a JavaScript response that re-throws a Ruby exception
      # in the browser
      def javascript_exception_response(exception)
        err  = "#{exception.class.name}: #{exception.message}\n  (in #{exception.backtrace[0]})"
        body = "throw Error(#{err.inspect})"
        [ 200, { "Content-Type" => "application/javascript", "Content-Length" => body.bytesize.to_s }, [ body ] ]
      end

      # Returns a CSS response that hides all elements on the page and
      # displays the exception
      def css_exception_response(exception)
        message   = "\n#{exception.class.name}: #{exception.message}"
        backtrace = "\n  #{exception.backtrace.first}"

        body = <<-CSS
          html {
            padding: 18px 36px;
          }

          head {
            display: block;
          }

          body {
            margin: 0;
            padding: 0;
          }

          body > * {
            display: none !important;
          }

          head:after, body:before, body:after {
            display: block !important;
          }

          head:after {
            font-family: sans-serif;
            font-size: large;
            font-weight: bold;
            content: "Error compiling CSS asset";
          }

          body:before, body:after {
            font-family: monospace;
            white-space: pre-wrap;
          }

          body:before {
            font-weight: bold;
            content: "#{escape_css_content(message)}";
          }

          body:after {
            content: "#{escape_css_content(backtrace)}";
          }
        CSS

        [ 200, { "Content-Type" => "text/css; charset=utf-8", "Content-Length" => body.bytesize.to_s }, [ body ] ]
      end

      # Escape special characters for use inside a CSS content("...") string
      def escape_css_content(content)
        content.
          gsub('\\', '\\\\005c ').
          gsub("\n", '\\\\000a ').
          gsub('"',  '\\\\0022 ').
          gsub('/',  '\\\\002f ')
      end

      # Test if `?body=1` or `body=true` query param is set
      def body_only?(env)
        env["QUERY_STRING"].to_s =~ /body=(1|t)/
      end

      def cache_headers(env, etag)
        headers = {}

        # Set caching headers
        headers["Cache-Control"] = "public"
        headers["ETag"]          = %("#{etag}")

        # If the request url contains a fingerprint, set a long
        # expires on the response
        if path_fingerprint(env["PATH_INFO"])
          headers["Cache-Control"] << ", max-age=31536000"

        # Otherwise set `must-revalidate` since the asset could be modified.
        else
          headers["Cache-Control"] << ", must-revalidate"
          headers["Vary"] = "Accept-Encoding"
        end

        headers
      end

      def headers(env, asset, length)
        headers = {}

        # Set content length header
        headers["Content-Length"] = length.to_s

        # Set content type header
        if type = asset.content_type
          # Set charset param for text/* mime types
          if type.start_with?("text/") && asset.charset
            type += "; charset=#{asset.charset}"
          end
          headers["Content-Type"] = type
        end

        headers.merge(cache_headers(env, asset.etag))
      end

      # Gets ETag fingerprint.
      #
      #     "foo-0aa2105d29558f3eb790d411d7d8fb66.js"
      #     # => "0aa2105d29558f3eb790d411d7d8fb66"
      #
      def path_fingerprint(path)
        path[/-([0-9a-f]{7,128})\.[^.]+\z/, 1]
      end
  end
end
