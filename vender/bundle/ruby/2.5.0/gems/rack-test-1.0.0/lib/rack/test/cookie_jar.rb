require 'uri'
require 'time'

module Rack
  module Test
    class Cookie # :nodoc:
      include Rack::Utils

      # :api: private
      attr_reader :name, :value

      # :api: private
      def initialize(raw, uri = nil, default_host = DEFAULT_HOST)
        @default_host = default_host
        uri ||= default_uri

        # separate the name / value pair from the cookie options
        @name_value_raw, options = raw.split(/[;,] */n, 2)

        @name, @value = parse_query(@name_value_raw, ';').to_a.first
        @options = parse_query(options, ';')

        @options['domain']  ||= (uri.host || default_host)
        @options['path']    ||= uri.path.sub(/\/[^\/]*\Z/, '')
      end

      def replaces?(other)
        [name.downcase, domain, path] == [other.name.downcase, other.domain, other.path]
      end

      # :api: private
      def raw
        @name_value_raw
      end

      # :api: private
      def empty?
        @value.nil? || @value.empty?
      end

      # :api: private
      def domain
        @options['domain']
      end

      def secure?
        @options.key?('secure')
      end

      def http_only?
        @options.key?('HttpOnly')
      end

      # :api: private
      def path
        ([*@options['path']].first.split(',').first || '/').strip
      end

      # :api: private
      def expires
        Time.parse(@options['expires']) if @options['expires']
      end

      # :api: private
      def expired?
        expires && expires < Time.now
      end

      # :api: private
      def valid?(uri)
        uri ||= default_uri

        uri.host = @default_host if uri.host.nil?

        real_domain = domain =~ /^\./ ? domain[1..-1] : domain
        (!secure? || (secure? && uri.scheme == 'https')) &&
          uri.host =~ Regexp.new("#{Regexp.escape(real_domain)}$", Regexp::IGNORECASE) &&
          uri.path =~ Regexp.new("^#{Regexp.escape(path)}")
      end

      # :api: private
      def matches?(uri)
        !expired? && valid?(uri)
      end

      # :api: private
      def <=>(other)
        # Orders the cookies from least specific to most
        [name, path, domain.reverse] <=> [other.name, other.path, other.domain.reverse]
      end

      def to_h
        @options.merge(
          'value'    => @value,
          'HttpOnly' => http_only?,
          'secure'   => secure?
        )
      end
      alias to_hash to_h

      protected

      def default_uri
        URI.parse('//' + @default_host + '/')
      end
    end

    class CookieJar # :nodoc:
      DELIMITER = '; '.freeze

      # :api: private
      def initialize(cookies = [], default_host = DEFAULT_HOST)
        @default_host = default_host
        @cookies = cookies
        @cookies.sort!
      end

      def [](name)
        cookies = hash_for(nil)
        # TODO: Should be case insensitive
        cookies[name.to_s] && cookies[name.to_s].value
      end

      def []=(name, value)
        merge("#{name}=#{Rack::Utils.escape(value)}")
      end

      def get_cookie(name)
        hash_for(nil).fetch(name, nil)
      end

      def delete(name)
        @cookies.reject! do |cookie|
          cookie.name == name
        end
      end

      def merge(raw_cookies, uri = nil)
        return unless raw_cookies

        if raw_cookies.is_a? String
          raw_cookies = raw_cookies.split("\n")
          raw_cookies.reject!(&:empty?)
        end

        raw_cookies.each do |raw_cookie|
          cookie = Cookie.new(raw_cookie, uri, @default_host)
          self << cookie if cookie.valid?(uri)
        end
      end

      def <<(new_cookie)
        @cookies.reject! do |existing_cookie|
          new_cookie.replaces?(existing_cookie)
        end

        @cookies << new_cookie
        @cookies.sort!
      end

      # :api: private
      def for(uri)
        hash_for(uri).values.map(&:raw).join(DELIMITER)
      end

      def to_hash
        cookies = {}

        hash_for(nil).each do |name, cookie|
          cookies[name] = cookie.value
        end

        cookies
      end

      protected

      def hash_for(uri = nil)
        cookies = {}

        # The cookies are sorted by most specific first. So, we loop through
        # all the cookies in order and add it to a hash by cookie name if
        # the cookie can be sent to the current URI. It's added to the hash
        # so that when we are done, the cookies will be unique by name and
        # we'll have grabbed the most specific to the URI.
        @cookies.each do |cookie|
          cookies[cookie.name] = cookie if !uri || cookie.matches?(uri)
        end

        cookies
      end
    end
  end
end
