# coding: utf-8

require 'json'
require 'time'

module Stoplight
  class Failure # rubocop:disable Style/Documentation
    TIME_FORMAT = '%Y-%m-%dT%H:%M:%S.%N%:z'.freeze

    # @return [String]
    attr_reader :error_class
    # @return [String]
    attr_reader :error_message
    # @return [Time]
    attr_reader :time

    # @param error [Exception]
    # @return (see #initialize)
    def self.from_error(error)
      new(error.class.name, error.message, Time.now)
    end

    # @param json [String]
    # @return (see #initialize)
    # @raise [JSON::ParserError]
    # @raise [ArgumentError]
    def self.from_json(json)
      object = JSON.parse(json)
      error_object = object['error']

      error_class = error_object['class']
      error_message = error_object['message']
      time = Time.parse(object['time'])

      new(error_class, error_message, time)
    end

    # @param error_class [String]
    # @param error_message [String]
    # @param time [Time]
    def initialize(error_class, error_message, time)
      @error_class = error_class
      @error_message = error_message
      @time = time
    end

    # @param other [Failure]
    # @return [Boolean]
    def ==(other)
      error_class == other.error_class &&
        error_message == other.error_message &&
        time == other.time
    end

    # @return [String]
    def to_json
      JSON.generate(
        error: {
          class: error_class,
          message: error_message
        },
        time: time.strftime(TIME_FORMAT)
      )
    end
  end
end
