module Chewy
  class Query
    module Nodes
      class Exists < Expr
        def initialize(name, options = {})
          @name = name.to_s
          @options = options
        end

        def !
          Nodes::Missing.new @name, null_value: true
        end

        def __render__
          {exists: {field: @name}}
        end
      end
    end
  end
end
