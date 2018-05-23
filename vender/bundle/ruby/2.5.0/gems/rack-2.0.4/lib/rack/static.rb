require "rack/file"
require "rack/utils"

module Rack

  # The Rack::Static middleware intercepts requests for static files
  # (javascript files, images, stylesheets, etc) based on the url prefixes or
  # route mappings passed in the options, and serves them using a Rack::File
  # object. This allows a Rack stack to serve both static and dynamic content.
  #
  # Examples:
  #
  # Serve all requests beginning with /media from the "media" folder located
  # in the current directory (ie media/*):
  #
  #     use Rack::Static, :urls => ["/media"]
  #
  # Serve all requests beginning with /css or /images from the folder "public"
  # in the current directory (ie public/css/* and public/images/*):
  #
  #     use Rack::Static, :urls => ["/css", "/images"], :root => "public"
  #
  # Serve all requests to / with "index.html" from the folder "public" in the
  # current directory (ie public/index.html):
  #
  #     use Rack::Static, :urls => {"/" => 'index.html'}, :root => 'public'
  #
  # Serve all requests normally from the folder "public" in the current
  # directory but uses index.html as default route for "/"
  #
  #     use Rack::Static, :urls => [""], :root => 'public', :index =>
  #     'index.html'
  #
  # Set custom HTTP Headers for based on rules:
  #
  #     use Rack::Static, :root => 'public',
  #         :header_rules => [
  #           [rule, {header_field => content, header_field => content}],
  #           [rule, {header_field => content}]
  #         ]
  #
  #  Rules for selecting files:
  #
  #  1) All files
  #     Provide the :all symbol
  #     :all => Matches every file
  #
  #  2) Folders
  #     Provide the folder path as a string
  #     '/folder' or '/folder/subfolder' => Matches files in a certain folder
  #
  #  3) File Extensions
  #     Provide the file extensions as an array
  #     ['css', 'js'] or %w(css js) => Matches files ending in .css or .js
  #
  #  4) Regular Expressions / Regexp
  #     Provide a regular expression
  #     %r{\.(?:css|js)\z} => Matches files ending in .css or .js
  #     /\.(?:eot|ttf|otf|woff2|woff|svg)\z/ => Matches files ending in
  #       the most common web font formats (.eot, .ttf, .otf, .woff2, .woff, .svg)
  #       Note: This Regexp is available as a shortcut, using the :fonts rule
  #
  #  5) Font Shortcut
  #     Provide the :fonts symbol
  #     :fonts => Uses the Regexp rule stated right above to match all common web font endings
  #
  #  Rule Ordering:
  #    Rules are applied in the order that they are provided.
  #    List rather general rules above special ones.
  #
  #  Complete example use case including HTTP header rules:
  #
  #     use Rack::Static, :root => 'public',
  #         :header_rules => [
  #           # Cache all static files in public caches (e.g. Rack::Cache)
  #           #  as well as in the browser
  #           [:all, {'Cache-Control' => 'public, max-age=31536000'}],
  #
  #           # Provide web fonts with cross-origin access-control-headers
  #           #  Firefox requires this when serving assets using a Content Delivery Network
  #           [:fonts, {'Access-Control-Allow-Origin' => '*'}]
  #         ]
  #
  class Static

    def initialize(app, options={})
      @app = app
      @urls = options[:urls] || ["/favicon.ico"]
      @index = options[:index]
      @gzip = options[:gzip]
      root = options[:root] || Dir.pwd

      # HTTP Headers
      @header_rules = options[:header_rules] || []
      # Allow for legacy :cache_control option while prioritizing global header_rules setting
      @header_rules.unshift([:all, {CACHE_CONTROL => options[:cache_control]}]) if options[:cache_control]

      @file_server = Rack::File.new(root)
    end

    def add_index_root?(path)
      @index && path =~ /\/$/
    end

    def overwrite_file_path(path)
      @urls.kind_of?(Hash) && @urls.key?(path) || add_index_root?(path)
    end

    def route_file(path)
      @urls.kind_of?(Array) && @urls.any? { |url| path.index(url) == 0 }
    end

    def can_serve(path)
      route_file(path) || overwrite_file_path(path)
    end

    def call(env)
      path = env[PATH_INFO]

      if can_serve(path)
        if overwrite_file_path(path)
          env[PATH_INFO] = (add_index_root?(path) ? path + @index : @urls[path])
        elsif @gzip && env['HTTP_ACCEPT_ENCODING'] =~ /\bgzip\b/
          path = env[PATH_INFO]
          env[PATH_INFO] += '.gz'
          response = @file_server.call(env)
          env[PATH_INFO] = path

          if response[0] == 404
            response = nil
          else
            if mime_type = Mime.mime_type(::File.extname(path), 'text/plain')
              response[1][CONTENT_TYPE] = mime_type
            end
            response[1]['Content-Encoding'] = 'gzip'
          end
        end

        path = env[PATH_INFO]
        response ||= @file_server.call(env)

        headers = response[1]
        applicable_rules(path).each do |rule, new_headers|
          new_headers.each { |field, content| headers[field] = content }
        end

        response
      else
        @app.call(env)
      end
    end

    # Convert HTTP header rules to HTTP headers
    def applicable_rules(path)
      @header_rules.find_all do |rule, new_headers|
        case rule
        when :all
          true
        when :fonts
          path =~ /\.(?:ttf|otf|eot|woff2|woff|svg)\z/
        when String
          path = ::Rack::Utils.unescape(path)
          path.start_with?(rule) || path.start_with?('/' + rule)
        when Array
          path =~ /\.(#{rule.join('|')})\z/
        when Regexp
          path =~ rule
        else
          false
        end
      end
    end

  end
end
