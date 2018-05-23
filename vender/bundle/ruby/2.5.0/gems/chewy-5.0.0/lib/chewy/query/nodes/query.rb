module Chewy
  class Query
    module Nodes
      class Query < Expr
        def initialize(query, options = {})
          @query = query
          @options = options
        end

        def __render__
          if @options.key?(:cache)
            {fquery: {query: @query, _cache: !!@options[:cache]}}
          else
            {query: @query}
          end
        end
      end
    end
  end
end
