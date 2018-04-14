# frozen_string_literal: true
require 'rack'

module Sidekiq
  module WebRouter
    GET = 'GET'
    DELETE = 'DELETE'
    POST = 'POST'
    PUT = 'PUT'
    PATCH = 'PATCH'
    HEAD = 'HEAD'

    ROUTE_PARAMS = 'rack.route_params'
    REQUEST_METHOD = 'REQUEST_METHOD'
    PATH_INFO = 'PATH_INFO'

    def get(path, &block)
      route(GET, path, &block)
    end

    def post(path, &block)
      route(POST, path, &block)
    end

    def put(path, &block)
      route(PUT, path, &block)
    end

    def patch(path, &block)
      route(PATCH, path, &block)
    end

    def delete(path, &block)
      route(DELETE, path, &block)
    end

    def route(method, path, &block)
      @routes ||= { GET => [], POST => [], PUT => [], PATCH => [], DELETE => [], HEAD => [] }

      @routes[method] << WebRoute.new(method, path, block)
      @routes[HEAD] << WebRoute.new(method, path, block) if method == GET
    end

    def match(env)
      request_method = env[REQUEST_METHOD]
      path_info = ::Rack::Utils.unescape env[PATH_INFO]

      # There are servers which send an empty string when requesting the root.
      # These servers should be ashamed of themselves.
      path_info = "/" if path_info == ""

      @routes[request_method].each do |route|
        if params = route.match(request_method, path_info)
          env[ROUTE_PARAMS] = params

          return WebAction.new(env, route.block)
        end
      end

      nil
    end
  end

  class WebRoute
    attr_accessor :request_method, :pattern, :block, :name

    NAMED_SEGMENTS_PATTERN = /\/([^\/]*):([^\.:$\/]+)/

    def initialize(request_method, pattern, block)
      @request_method = request_method
      @pattern = pattern
      @block = block
    end

    def matcher
      @matcher ||= compile
    end

    def compile
      if pattern.match(NAMED_SEGMENTS_PATTERN)
        p = pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^$/]+)')

        Regexp.new("\\A#{p}\\Z")
      else
        pattern
      end
    end

    def match(request_method, path)
      case matcher
      when String
        {} if path == matcher
      else
        if path_match = path.match(matcher)
          Hash[path_match.names.map(&:to_sym).zip(path_match.captures)]
        end
      end
    end
  end
end
