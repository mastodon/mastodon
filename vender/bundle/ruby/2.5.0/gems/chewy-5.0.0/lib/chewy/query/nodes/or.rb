module Chewy
  class Query
    module Nodes
      class Or < Expr
        def initialize(*nodes)
          @options = nodes.extract_options!
          @nodes = nodes.flatten.map { |node| node.is_a?(self.class) ? node.__nodes__ : node }.flatten
        end

        def __nodes__
          @nodes
        end

        def __render__
          nodes = @nodes.map(&:__render__)
          if @options.key?(:cache)
            {or: {filters: nodes, _cache: !!@options[:cache]}}
          else
            {or: nodes}
          end
        end
      end
    end
  end
end
