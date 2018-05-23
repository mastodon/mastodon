module Chewy
  class Query
    module Nodes
      class Not < Expr
        def initialize(expr, options = {})
          @expr = expr
          @options = options
        end

        def !
          @expr
        end

        def __render__
          expr = @expr.__render__
          if @options.key?(:cache)
            {not: {filter: expr, _cache: !!@options[:cache]}}
          else
            {not: expr}
          end
        end
      end
    end
  end
end
