# frozen_string_literal: true
require 'erb'

require 'sidekiq'
require 'sidekiq/api'
require 'sidekiq/paginator'
require 'sidekiq/web/helpers'

require 'sidekiq/web/router'
require 'sidekiq/web/action'
require 'sidekiq/web/application'

require 'rack/protection'

require 'rack/builder'
require 'rack/file'
require 'rack/session/cookie'

module Sidekiq
  class Web
    ROOT = File.expand_path("#{File.dirname(__FILE__)}/../../web")
    VIEWS = "#{ROOT}/views"
    LOCALES = ["#{ROOT}/locales"]
    LAYOUT = "#{VIEWS}/layout.erb"
    ASSETS = "#{ROOT}/assets"

    DEFAULT_TABS = {
      "Dashboard" => '',
      "Busy"      => 'busy',
      "Queues"    => 'queues',
      "Retries"   => 'retries',
      "Scheduled" => 'scheduled',
      "Dead"      => 'morgue',
    }

    class << self
      def settings
        self
      end

      def middlewares
        @middlewares ||= []
      end

      def use(*middleware_args, &block)
        middlewares << [middleware_args, block]
      end

      def default_tabs
        DEFAULT_TABS
      end

      def custom_tabs
        @custom_tabs ||= {}
      end
      alias_method :tabs, :custom_tabs

      def locales
        @locales ||= LOCALES
      end

      def views
        @views ||= VIEWS
      end

      def enable(*opts)
        opts.each {|key| set(key, true) }
      end

      def disable(*opts)
        opts.each {|key| set(key, false) }
      end

      # Helper for the Sinatra syntax: Sidekiq::Web.set(:session_secret, Rails.application.secrets...)
      def set(attribute, value)
        send(:"#{attribute}=", value)
      end

      attr_accessor :app_url, :session_secret, :redis_pool, :sessions
      attr_writer :locales, :views
    end

    def self.inherited(child)
      child.app_url = self.app_url
      child.session_secret = self.session_secret
      child.redis_pool = self.redis_pool
      child.sessions = self.sessions
    end

    def settings
      self.class.settings
    end

    def use(*middleware_args, &block)
      middlewares << [middleware_args, block]
    end

    def middlewares
      @middlewares ||= Web.middlewares.dup
    end

    def call(env)
      app.call(env)
    end

    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def app
      @app ||= build
    end

    def enable(*opts)
      opts.each {|key| set(key, true) }
    end

    def disable(*opts)
      opts.each {|key| set(key, false) }
    end

    def set(attribute, value)
      send(:"#{attribute}=", value)
    end

    # Default values
    set :sessions, true

    attr_writer :sessions

    def sessions
      unless instance_variable_defined?("@sessions")
        @sessions = self.class.sessions
        @sessions = @sessions.to_hash.dup if @sessions.respond_to?(:to_hash)
      end

      @sessions
    end

    def self.register(extension)
      extension.registered(WebApplication)
    end

    private

    def using?(middleware)
      middlewares.any? do |(m,_)|
        m.kind_of?(Array) && (m[0] == middleware || m[0].kind_of?(middleware))
      end
    end

    def build_sessions
      middlewares = self.middlewares

      unless using?(::Rack::Protection) || ENV['RACK_ENV'] == 'test'
        middlewares.unshift [[::Rack::Protection, { use: :authenticity_token }], nil]
      end

      s = sessions
      return unless s

      unless using? ::Rack::Session::Cookie
        unless secret = Web.session_secret
          require 'securerandom'
          secret = SecureRandom.hex(64)
        end

        options = { secret: secret }
        options = options.merge(s.to_hash) if s.respond_to? :to_hash

        middlewares.unshift [[::Rack::Session::Cookie, options], nil]
      end
    end

    def build
      build_sessions

      middlewares = self.middlewares
      klass = self.class

      ::Rack::Builder.new do
        %w(stylesheets javascripts images).each do |asset_dir|
          map "/#{asset_dir}" do
            run ::Rack::File.new("#{ASSETS}/#{asset_dir}", { 'Cache-Control' => 'public, max-age=86400' })
          end
        end

        middlewares.each {|middleware, block| use(*middleware, &block) }

        run WebApplication.new(klass)
      end
    end
  end

  Sidekiq::WebApplication.helpers WebHelpers
  Sidekiq::WebApplication.helpers Sidekiq::Paginator

  Sidekiq::WebAction.class_eval "def _render\n#{ERB.new(File.read(Web::LAYOUT)).src}\nend"
end

if defined?(::ActionDispatch::Request::Session) &&
    !::ActionDispatch::Request::Session.method_defined?(:each)
  # mperham/sidekiq#2460
  # Rack apps can't reuse the Rails session store without
  # this monkeypatch, fixed in Rails 5.
  class ActionDispatch::Request::Session
    def each(&block)
      hash = self.to_hash
      hash.each(&block)
    end
  end
end
