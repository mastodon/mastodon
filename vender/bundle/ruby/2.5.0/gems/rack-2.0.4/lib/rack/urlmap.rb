module Rack
  # Rack::URLMap takes a hash mapping urls or paths to apps, and
  # dispatches accordingly.  Support for HTTP/1.1 host names exists if
  # the URLs start with <tt>http://</tt> or <tt>https://</tt>.
  #
  # URLMap modifies the SCRIPT_NAME and PATH_INFO such that the part
  # relevant for dispatch is in the SCRIPT_NAME, and the rest in the
  # PATH_INFO.  This should be taken care of when you need to
  # reconstruct the URL in order to create links.
  #
  # URLMap dispatches in such a way that the longest paths are tried
  # first, since they are most specific.

  class URLMap
    NEGATIVE_INFINITY = -1.0 / 0.0
    INFINITY = 1.0 / 0.0

    def initialize(map = {})
      remap(map)
    end

    def remap(map)
      @mapping = map.map { |location, app|
        if location =~ %r{\Ahttps?://(.*?)(/.*)}
          host, location = $1, $2
        else
          host = nil
        end

        unless location[0] == ?/
          raise ArgumentError, "paths need to start with /"
        end

        location = location.chomp('/')
        match = Regexp.new("^#{Regexp.quote(location).gsub('/', '/+')}(.*)", nil, 'n')

        [host, location, match, app]
      }.sort_by do |(host, location, _, _)|
        [host ? -host.size : INFINITY, -location.size]
      end
    end

    def call(env)
      path        = env[PATH_INFO]
      script_name = env[SCRIPT_NAME]
      http_host   = env[HTTP_HOST]
      server_name = env[SERVER_NAME]
      server_port = env[SERVER_PORT]

      is_same_server = casecmp?(http_host, server_name) ||
                       casecmp?(http_host, "#{server_name}:#{server_port}")

      @mapping.each do |host, location, match, app|
        unless casecmp?(http_host, host) \
            || casecmp?(server_name, host) \
            || (!host && is_same_server)
          next
        end

        next unless m = match.match(path.to_s)

        rest = m[1]
        next unless !rest || rest.empty? || rest[0] == ?/

        env[SCRIPT_NAME] = (script_name + location)
        env[PATH_INFO] = rest

        return app.call(env)
      end

      [404, {CONTENT_TYPE => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{path}"]]

    ensure
      env[PATH_INFO]   = path
      env[SCRIPT_NAME] = script_name
    end

    private
    def casecmp?(v1, v2)
      # if both nil, or they're the same string
      return true if v1 == v2

      # if either are nil... (but they're not the same)
      return false if v1.nil?
      return false if v2.nil?

      # otherwise check they're not case-insensitive the same
      v1.casecmp(v2).zero?
    end
  end
end
