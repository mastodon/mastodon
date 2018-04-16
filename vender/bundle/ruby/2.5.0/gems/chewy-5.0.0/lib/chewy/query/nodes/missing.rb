module Chewy
  class Query
    module Nodes
      class Missing < Expr
        def initialize(name, options = {})
          @name = name.to_s
          @options = options.reverse_merge(existence: true, null_value: false)
        end

        def !
          Nodes::Exists.new @name
        end

        def __render__
          {missing: {field: @name}.merge(@options.slice(:existence, :null_value))}
        end
      end
    end
  end
end
