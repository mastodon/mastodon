require 'sprockets/autoload'
require 'sprockets/digest_utils'

module Sprockets
  # Public: Sass CSS minifier.
  #
  # To accept the default options
  #
  #     environment.register_bundle_processor 'text/css',
  #       Sprockets::SassCompressor
  #
  # Or to pass options to the Sass::Engine class.
  #
  #     environment.register_bundle_processor 'text/css',
  #       Sprockets::SassCompressor.new({ ... })
  #
  class SassCompressor
    VERSION = '1'

    # Public: Return singleton instance with default options.
    #
    # Returns SassCompressor object.
    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def self.cache_key
      instance.cache_key
    end

    attr_reader :cache_key

    def initialize(options = {})
      @options = {
        syntax: :scss,
        cache: false,
        read_cache: false,
        style: :compressed
      }.merge(options).freeze
      @cache_key = "#{self.class.name}:#{Autoload::Sass::VERSION}:#{VERSION}:#{DigestUtils.digest(options)}".freeze
    end

    def call(input)
      Autoload::Sass::Engine.new(input[:data], @options).render
    end
  end
end
