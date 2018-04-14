module Chewy
  class Query
    module Nodes
      class Raw < Expr
        def initialize(raw)
          @raw = raw
        end

        def __render__
          @raw
        end
      end
    end
  end
end
