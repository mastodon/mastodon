require 'sprockets/autoload'

module Sprockets
  # Processor engine class for the EJS compiler. Depends on the `ejs` gem.
  #
  # For more infomation see:
  #
  #   https://github.com/sstephenson/ruby-ejs
  #
  module EjsProcessor
    VERSION = '1'

    def self.cache_key
      @cache_key ||= "#{name}:#{VERSION}".freeze
    end

    # Compile template data with EJS compiler.
    #
    # Returns a JS function definition String. The result should be
    # assigned to a JS variable.
    #
    #     # => "function(obj){...}"
    #
    def self.call(input)
      data = input[:data]
      input[:cache].fetch([cache_key, data]) do
        Autoload::EJS.compile(data)
      end
    end
  end
end
