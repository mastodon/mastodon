require File.expand_path("../url_encoded", __FILE__)
require 'securerandom'

module Faraday
  class Request::Multipart < Request::UrlEncoded
    self.mime_type = 'multipart/form-data'.freeze
    DEFAULT_BOUNDARY_PREFIX = "-----------RubyMultipartPost".freeze unless defined? DEFAULT_BOUNDARY_PREFIX

    def call(env)
      match_content_type(env) do |params|
        env.request.boundary ||= unique_boundary
        env.request_headers[CONTENT_TYPE] += "; boundary=#{env.request.boundary}"
        env.body = create_multipart(env, params)
      end
      @app.call env
    end

    def process_request?(env)
      type = request_type(env)
      env.body.respond_to?(:each_key) and !env.body.empty? and (
        (type.empty? and has_multipart?(env.body)) or
        type == self.class.mime_type
      )
    end

    def has_multipart?(obj)
      # string is an enum in 1.8, returning list of itself
      if obj.respond_to?(:each) && !obj.is_a?(String)
        (obj.respond_to?(:values) ? obj.values : obj).each do |val|
          return true if (val.respond_to?(:content_type) || has_multipart?(val))
        end
      end
      false
    end

    def create_multipart(env, params)
      boundary = env.request.boundary
      parts = process_params(params) do |key, value|
        Faraday::Parts::Part.new(boundary, key, value)
      end
      parts << Faraday::Parts::EpiloguePart.new(boundary)

      body = Faraday::CompositeReadIO.new(parts)
      env.request_headers[Faraday::Env::ContentLength] = body.length.to_s
      return body
    end

    def unique_boundary
      "#{DEFAULT_BOUNDARY_PREFIX}-#{SecureRandom.hex}"
    end

    def process_params(params, prefix = nil, pieces = nil, &block)
      params.inject(pieces || []) do |all, (key, value)|
        key = "#{prefix}[#{key}]" if prefix

        case value
        when Array
          values = value.inject([]) { |a,v| a << [nil, v] }
          process_params(values, key, all, &block)
        when Hash
          process_params(value, key, all, &block)
        else
          all << block.call(key, value)
        end
      end
    end
  end
end
