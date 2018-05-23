require 'rack/file'
require 'rack/body_proxy'

module Rack

  # = Sendfile
  #
  # The Sendfile middleware intercepts responses whose body is being
  # served from a file and replaces it with a server specific X-Sendfile
  # header. The web server is then responsible for writing the file contents
  # to the client. This can dramatically reduce the amount of work required
  # by the Ruby backend and takes advantage of the web server's optimized file
  # delivery code.
  #
  # In order to take advantage of this middleware, the response body must
  # respond to +to_path+ and the request must include an X-Sendfile-Type
  # header. Rack::File and other components implement +to_path+ so there's
  # rarely anything you need to do in your application. The X-Sendfile-Type
  # header is typically set in your web servers configuration. The following
  # sections attempt to document
  #
  # === Nginx
  #
  # Nginx supports the X-Accel-Redirect header. This is similar to X-Sendfile
  # but requires parts of the filesystem to be mapped into a private URL
  # hierarchy.
  #
  # The following example shows the Nginx configuration required to create
  # a private "/files/" area, enable X-Accel-Redirect, and pass the special
  # X-Sendfile-Type and X-Accel-Mapping headers to the backend:
  #
  #   location ~ /files/(.*) {
  #     internal;
  #     alias /var/www/$1;
  #   }
  #
  #   location / {
  #     proxy_redirect     off;
  #
  #     proxy_set_header   Host                $host;
  #     proxy_set_header   X-Real-IP           $remote_addr;
  #     proxy_set_header   X-Forwarded-For     $proxy_add_x_forwarded_for;
  #
  #     proxy_set_header   X-Sendfile-Type     X-Accel-Redirect;
  #     proxy_set_header   X-Accel-Mapping     /var/www/=/files/;
  #
  #     proxy_pass         http://127.0.0.1:8080/;
  #   }
  #
  # Note that the X-Sendfile-Type header must be set exactly as shown above.
  # The X-Accel-Mapping header should specify the location on the file system,
  # followed by an equals sign (=), followed name of the private URL pattern
  # that it maps to. The middleware performs a simple substitution on the
  # resulting path.
  #
  # See Also: http://wiki.codemongers.com/NginxXSendfile
  #
  # === lighttpd
  #
  # Lighttpd has supported some variation of the X-Sendfile header for some
  # time, although only recent version support X-Sendfile in a reverse proxy
  # configuration.
  #
  #   $HTTP["host"] == "example.com" {
  #      proxy-core.protocol = "http"
  #      proxy-core.balancer = "round-robin"
  #      proxy-core.backends = (
  #        "127.0.0.1:8000",
  #        "127.0.0.1:8001",
  #        ...
  #      )
  #
  #      proxy-core.allow-x-sendfile = "enable"
  #      proxy-core.rewrite-request = (
  #        "X-Sendfile-Type" => (".*" => "X-Sendfile")
  #      )
  #    }
  #
  # See Also: http://redmine.lighttpd.net/wiki/lighttpd/Docs:ModProxyCore
  #
  # === Apache
  #
  # X-Sendfile is supported under Apache 2.x using a separate module:
  #
  # https://tn123.org/mod_xsendfile/
  #
  # Once the module is compiled and installed, you can enable it using
  # XSendFile config directive:
  #
  #   RequestHeader Set X-Sendfile-Type X-Sendfile
  #   ProxyPassReverse / http://localhost:8001/
  #   XSendFile on
  #
  # === Mapping parameter
  #
  # The third parameter allows for an overriding extension of the
  # X-Accel-Mapping header. Mappings should be provided in tuples of internal to
  # external. The internal values may contain regular expression syntax, they
  # will be matched with case indifference.

  class Sendfile
    def initialize(app, variation=nil, mappings=[])
      @app = app
      @variation = variation
      @mappings = mappings.map do |internal, external|
        [/^#{internal}/i, external]
      end
    end

    def call(env)
      status, headers, body = @app.call(env)
      if body.respond_to?(:to_path)
        case type = variation(env)
        when 'X-Accel-Redirect'
          path = ::File.expand_path(body.to_path)
          if url = map_accel_path(env, path)
            headers[CONTENT_LENGTH] = '0'
            headers[type] = url
            obody = body
            body = Rack::BodyProxy.new([]) do
              obody.close if obody.respond_to?(:close)
            end
          else
            env[RACK_ERRORS].puts "X-Accel-Mapping header missing"
          end
        when 'X-Sendfile', 'X-Lighttpd-Send-File'
          path = ::File.expand_path(body.to_path)
          headers[CONTENT_LENGTH] = '0'
          headers[type] = path
          obody = body
          body = Rack::BodyProxy.new([]) do
            obody.close if obody.respond_to?(:close)
          end
        when '', nil
        else
          env[RACK_ERRORS].puts "Unknown x-sendfile variation: '#{type}'.\n"
        end
      end
      [status, headers, body]
    end

    private
    def variation(env)
      @variation ||
        env['sendfile.type'] ||
        env['HTTP_X_SENDFILE_TYPE']
    end

    def map_accel_path(env, path)
      if mapping = @mappings.find { |internal,_| internal =~ path }
        path.sub(*mapping)
      elsif mapping = env['HTTP_X_ACCEL_MAPPING']
        internal, external = mapping.split('=', 2).map(&:strip)
        path.sub(/^#{internal}/i, external)
      end
    end
  end
end
