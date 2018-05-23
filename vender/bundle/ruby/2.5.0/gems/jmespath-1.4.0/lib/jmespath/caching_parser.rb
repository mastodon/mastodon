require 'thread'

module JMESPath
  class CachingParser

    def initialize(options = {})
      @parser = options[:parser] || Parser.new(options)
      @mutex = Mutex.new
      @cache = {}
    end

    def parse(expression)
      if cached = @cache[expression]
        cached
      else
        cache_expression(expression)
      end
    end

    private

    def cache_expression(expression)
      @mutex.synchronize do
        @cache.clear if @cache.size > 1000
        @cache[expression] = @parser.parse(expression)
      end
    end

  end
end
