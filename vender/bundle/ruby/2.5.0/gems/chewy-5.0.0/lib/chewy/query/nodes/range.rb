module Chewy
  class Query
    module Nodes
      class Range < Expr
        EXECUTION = {
          i: :index,
          index: :index,
          f: :fielddata,
          fielddata: :fielddata
        }.freeze

        def initialize(name, *args)
          @name = name.to_s
          @options = args.extract_options!
          @range = @options.select { |k, _v| %i[gt lt].include?(k) }
          @bounds = @options.select { |k, _v| %i[left_closed right_closed].include?(k) }
          execution = EXECUTION[args.first.to_sym] if args.first
          @options[:execution] = execution if execution
        end

        def &(other)
          if other.is_a?(self.class) && other.__name__ == @name
            state = __state__.merge(other.__state__)

            cache = other.__options__[:cache] || @options[:cache]
            state[:cache] = cache unless cache.nil?

            execution = other.__options__[:execution] || @options[:execution]
            state[:execution] = execution unless execution.nil?

            self.class.new(@name, state)
          else
            super
          end
        end

        def __name__
          @name
        end

        def __state__
          @range.merge(@bounds)
        end

        def __options__
          @options
        end

        def __render__
          body = {}
          body[@bounds[:left_closed] ? :gte : :gt] = @range[:gt] if @range.key?(:gt)
          body[@bounds[:right_closed] ? :lte : :lt] = @range[:lt] if @range.key?(:lt)

          filter = {@name => body}
          filter[:_cache] = !!@options[:cache] if @options.key?(:cache)
          filter.merge!(@options.slice(:execution))

          {range: filter}
        end
      end
    end
  end
end
