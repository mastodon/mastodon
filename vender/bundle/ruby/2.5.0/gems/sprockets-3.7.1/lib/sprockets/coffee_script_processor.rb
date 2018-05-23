require 'sprockets/autoload'

module Sprockets
  # Processor engine class for the CoffeeScript compiler.
  # Depends on the `coffee-script` and `coffee-script-source` gems.
  #
  # For more infomation see:
  #
  #   https://github.com/josh/ruby-coffee-script
  #
  module CoffeeScriptProcessor
    VERSION = '1'

    def self.cache_key
      @cache_key ||= "#{name}:#{Autoload::CoffeeScript::Source.version}:#{VERSION}".freeze
    end

    def self.call(input)
      data = input[:data]
      input[:cache].fetch([self.cache_key, data]) do
        Autoload::CoffeeScript.compile(data)
      end
    end
  end
end
