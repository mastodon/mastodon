require "fog/core"
require "multi_json"
require File.expand_path("../json/version", __FILE__)

module Fog
  # The {JSON} module includes functionality that is common between APIs using JSON to send and
  # receive data.
  #
  # The intent is to provide common code for provider APIs using JSON but not require it for those
  # using XML.
  #
  module JSON
    class EncodeError < Fog::Errors::Error; end
    class DecodeError < Fog::Errors::Error; end

    # This cleans up Time objects to be ISO8601 format
    #
    def self.sanitize(data)
      case data
      when Array
        data.map { |datum| sanitize(datum) }
      when Hash
        data.each { |key, value| data[key] = sanitize(value) }
      when ::Time
        data.strftime("%Y-%m-%dT%H:%M:%SZ")
      else
        data
      end
    end

    # Do the MultiJson introspection at this level so we can define our encode/decode methods and
    # perform the introspection only once rather than once per call.
    def self.encode(obj)
      MultiJson.encode(obj)
    rescue => err
      raise EncodeError.slurp(err)
    end

    def self.decode(obj)
      MultiJson.decode(obj)
    rescue => err
      raise DecodeError.slurp(err)
    end
  end
end
