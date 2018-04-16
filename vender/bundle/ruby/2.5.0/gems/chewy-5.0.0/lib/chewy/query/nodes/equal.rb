module Chewy
  class Query
    module Nodes
      class Equal < Expr
        EXECUTION = {
          :| => :or,
          :or => :or,
          :& => :and,
          :and => :and,
          :b => :bool,
          :bool => :bool,
          :f => :fielddata,
          :fielddata => :fielddata
        }.freeze

        def initialize(name, value, *args)
          @name = name.to_s
          @value = value
          @options = args.extract_options!
          execution = EXECUTION[args.first.to_sym] if args.first
          @options[:execution] = execution if execution
        end

        def __render__
          filter = (@value.is_a?(Array) ? :terms : :term)
          body = {@name => @value}
          body.merge!(@options.slice(:execution)) if filter == :terms
          body[:_cache] = !!@options[:cache] if @options.key?(:cache)
          {filter => body}
        end
      end
    end
  end
end
