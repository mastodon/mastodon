require 'thread'
require 'cgi'
require 'set'
require 'forwardable'

# Public: This is the main namespace for Faraday.  You can either use it to
# create Faraday::Connection objects, or access it directly.
#
# Examples
#
#   Faraday.get "http://faraday.com"
#
#   conn = Faraday.new "http://faraday.com"
#   conn.get '/'
#
module Faraday
  VERSION = "0.14.0"

  class << self
    # Public: Gets or sets the root path that Faraday is being loaded from.
    # This is the root from where the libraries are auto-loaded from.
    attr_accessor :root_path

    # Public: Gets or sets the path that the Faraday libs are loaded from.
    attr_accessor :lib_path

    # Public: Gets or sets the Symbol key identifying a default Adapter to use
    # for the default Faraday::Connection.
    attr_reader :default_adapter

    # Public: Sets the default Faraday::Connection for simple scripts that
    # access the Faraday constant directly.
    #
    #     Faraday.get "https://faraday.com"
    attr_writer :default_connection

    # Public: Tells faraday to ignore the environment proxy (http_proxy).
    attr_accessor :ignore_env_proxy

    # Public: Initializes a new Faraday::Connection.
    #
    # url     - The optional String base URL to use as a prefix for all
    #           requests.  Can also be the options Hash.
    # options - The optional Hash used to configure this Faraday::Connection.
    #           Any of these values will be set on every request made, unless
    #           overridden for a specific request.
    #           :url     - String base URL.
    #           :params  - Hash of URI query unencoded key/value pairs.
    #           :headers - Hash of unencoded HTTP header key/value pairs.
    #           :request - Hash of request options.
    #           :ssl     - Hash of SSL options.
    #           :proxy   - Hash of Proxy options.
    #
    # Examples
    #
    #   Faraday.new 'http://faraday.com'
    #
    #   # http://faraday.com?page=1
    #   Faraday.new 'http://faraday.com', :params => {:page => 1}
    #
    #   # same
    #
    #   Faraday.new :url => 'http://faraday.com',
    #     :params => {:page => 1}
    #
    # Returns a Faraday::Connection.
    def new(url = nil, options = nil)
      block = block_given? ? Proc.new : nil
      options = options ? default_connection_options.merge(options) : default_connection_options
      Faraday::Connection.new(url, options, &block)
    end

    # Internal: Requires internal Faraday libraries.
    #
    # *libs - One or more relative String names to Faraday classes.
    #
    # Returns nothing.
    def require_libs(*libs)
      libs.each do |lib|
        require "#{lib_path}/#{lib}"
      end
    end

    # Public: Updates default adapter while resetting
    # #default_connection.
    #
    # Returns the new default_adapter.
    def default_adapter=(adapter)
      @default_connection = nil
      @default_adapter = adapter
    end

    alias require_lib require_libs

    def respond_to?(symbol, include_private = false)
      default_connection.respond_to?(symbol, include_private) || super
    end

  private
    # Internal: Proxies method calls on the Faraday constant to
    # #default_connection.
    def method_missing(name, *args, &block)
      default_connection.send(name, *args, &block)
    end
  end

  self.ignore_env_proxy = false
  self.root_path = File.expand_path "..", __FILE__
  self.lib_path = File.expand_path "../faraday", __FILE__
  self.default_adapter = :net_http

  # Gets the default connection used for simple scripts.
  #
  # Returns a Faraday::Connection, configured with the #default_adapter.
  def self.default_connection
    @default_connection ||= Connection.new(default_connection_options)
  end

  # Gets the default connection options used when calling Faraday#new.
  #
  # Returns a Faraday::ConnectionOptions.
  def self.default_connection_options
    @default_connection_options ||= ConnectionOptions.new
  end

  # Public: Sets the default options used when calling Faraday#new.
  def self.default_connection_options=(options)
    @default_connection = nil
    @default_connection_options = ConnectionOptions.from(options)
  end

  unless const_defined? :Timer
    require 'timeout'
    Timer = Timeout
  end

  # Public: Adds the ability for other modules to register and lookup
  # middleware classes.
  module MiddlewareRegistry
    # Public: Register middleware class(es) on the current module.
    #
    # mapping - A Hash mapping Symbol keys to classes. Classes can be expressed
    #           as fully qualified constant, or a Proc that will be lazily
    #           called to return the former.
    #
    # Examples
    #
    #   module Faraday
    #     class Whatever
    #       # Middleware looked up by :foo returns Faraday::Whatever::Foo.
    #       register_middleware :foo => Foo
    #
    #       # Middleware looked up by :bar returns Faraday::Whatever.const_get(:Bar)
    #       register_middleware :bar => :Bar
    #
    #       # Middleware looked up by :baz requires 'baz' and returns Faraday::Whatever.const_get(:Baz)
    #       register_middleware :baz => [:Baz, 'baz']
    #     end
    #   end
    #
    # Returns nothing.
    def register_middleware(autoload_path = nil, mapping = nil)
      if mapping.nil?
        mapping = autoload_path
        autoload_path = nil
      end
      middleware_mutex do
        @middleware_autoload_path = autoload_path if autoload_path
        (@registered_middleware ||= {}).update(mapping)
      end
    end

    # Public: Lookup middleware class with a registered Symbol shortcut.
    #
    # key - The Symbol key for the registered middleware.
    #
    # Examples
    #
    #   module Faraday
    #     class Whatever
    #       register_middleware :foo => Foo
    #     end
    #   end
    #
    #   Faraday::Whatever.lookup_middleware(:foo)
    #   # => Faraday::Whatever::Foo
    #
    # Returns a middleware Class.
    def lookup_middleware(key)
      load_middleware(key) ||
        raise(Faraday::Error.new("#{key.inspect} is not registered on #{self}"))
    end

    def middleware_mutex(&block)
      @middleware_mutex ||= begin
        require 'monitor'
        Monitor.new
      end
      @middleware_mutex.synchronize(&block)
    end

    def fetch_middleware(key)
      defined?(@registered_middleware) && @registered_middleware[key]
    end

    def load_middleware(key)
      value = fetch_middleware(key)
      case value
      when Module
        value
      when Symbol, String
        middleware_mutex do
          @registered_middleware[key] = const_get(value)
        end
      when Proc
        middleware_mutex do
          @registered_middleware[key] = value.call
        end
      when Array
        middleware_mutex do
          const, path = value
          if root = @middleware_autoload_path
            path = "#{root}/#{path}"
          end
          require(path)
          @registered_middleware[key] = const
        end
        load_middleware(key)
      end
    end
  end

  def self.const_missing(name)
    if name.to_sym == :Builder
      warn "Faraday::Builder is now Faraday::RackBuilder."
      const_set name, RackBuilder
    else
      super
    end
  end

  require_libs "utils", "options", "connection", "rack_builder", "parameters",
    "middleware", "adapter", "request", "response", "upload_io", "error"

  if !ENV["FARADAY_NO_AUTOLOAD"]
    require_lib 'autoload'
  end
end
