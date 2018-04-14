require 'sprockets/autoload'

module Sprockets
  # Processor engine class for the Eco compiler. Depends on the `eco` gem.
  #
  # For more infomation see:
  #
  #   https://github.com/sstephenson/ruby-eco
  #   https://github.com/sstephenson/eco
  #
  module EcoProcessor
    VERSION = '1'

    def self.cache_key
      @cache_key ||= "#{name}:#{Autoload::Eco::Source::VERSION}:#{VERSION}".freeze
    end

    # Compile template data with Eco compiler.
    #
    # Returns a JS function definition String. The result should be
    # assigned to a JS variable.
    #
    #     # => "function(...) {...}"
    #
    def self.call(input)
      data = input[:data]
      input[:cache].fetch([cache_key, data]) do
        Autoload::Eco.compile(data)
      end
    end
  end
end
