module Chewy
  class Query
    module Nodes
      class Prefix < Expr
        def initialize(name, value, options = {})
          @name = name.to_s
          @value = value
          @options = options
        end

        def __render__
          filter = {prefix: {@name => @value}}
          filter[:prefix][:_cache] = !!@options[:cache] if @options.key?(:cache)
          filter
        end
      end
    end
  end
end
