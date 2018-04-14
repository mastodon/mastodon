require 'thread'

module Nokogiri
  module CSS
    class Parser < Racc::Parser
      @cache_on = true
      @cache    = {}
      @mutex    = Mutex.new

      class << self
        # Turn on CSS parse caching
        attr_accessor :cache_on
        alias :cache_on? :cache_on
        alias :set_cache :cache_on=

        # Get the css selector in +string+ from the cache
        def [] string
          return unless @cache_on
          @mutex.synchronize { @cache[string] }
        end

        # Set the css selector in +string+ in the cache to +value+
        def []= string, value
          return value unless @cache_on
          @mutex.synchronize { @cache[string] = value }
        end

        # Clear the cache
        def clear_cache
          @mutex.synchronize { @cache = {} }
        end

        # Execute +block+ without cache
        def without_cache &block
          tmp = @cache_on
          @cache_on = false
          block.call
          @cache_on = tmp
        end

        ###
        # Parse this CSS selector in +selector+.  Returns an AST.
        def parse selector
          @warned ||= false
          unless @warned
            $stderr.puts('Nokogiri::CSS::Parser.parse is deprecated, call Nokogiri::CSS.parse(), this will be removed August 1st or version 1.4.0 (whichever is first)')
            @warned = true
          end
          new.parse selector
        end
      end

      # Create a new CSS parser with respect to +namespaces+
      def initialize namespaces = {}
        @tokenizer  = Tokenizer.new
        @namespaces = namespaces
        super()
      end

      def parse string
        @tokenizer.scan_setup string
        do_parse
      end

      def next_token
        @tokenizer.next_token
      end

      # Get the xpath for +string+ using +options+
      def xpath_for string, options={}
        key = "#{string}#{options[:ns]}#{options[:prefix]}"
        v = self.class[key]
        return v if v

        args = [
          options[:prefix] || '//',
          options[:visitor] || XPathVisitor.new
        ]
        self.class[key] = parse(string).map { |ast|
          ast.to_xpath(*args)
        }
      end

      # On CSS parser error, raise an exception
      def on_error error_token_id, error_value, value_stack
        after = value_stack.compact.last
        raise SyntaxError.new("unexpected '#{error_value}' after '#{after}'")
      end
    end
  end
end
