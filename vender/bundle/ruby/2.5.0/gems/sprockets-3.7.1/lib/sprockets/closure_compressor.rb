require 'sprockets/autoload'
require 'sprockets/digest_utils'

module Sprockets
  # Public: Closure Compiler minifier.
  #
  # To accept the default options
  #
  #     environment.register_bundle_processor 'application/javascript',
  #       Sprockets::ClosureCompressor
  #
  # Or to pass options to the Closure::Compiler class.
  #
  #     environment.register_bundle_processor 'application/javascript',
  #       Sprockets::ClosureCompressor.new({ ... })
  #
  class ClosureCompressor
    VERSION = '1'

    # Public: Return singleton instance with default options.
    #
    # Returns ClosureCompressor object.
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
      @options = options
      @cache_key = "#{self.class.name}:#{Autoload::Closure::VERSION}:#{Autoload::Closure::COMPILER_VERSION}:#{VERSION}:#{DigestUtils.digest(options)}".freeze
    end

    def call(input)
      @compiler ||= Autoload::Closure::Compiler.new(@options)
      @compiler.compile(input[:data])
    end
  end
end
