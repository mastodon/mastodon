module Chewy
  class Query
    module Nodes
      class MatchAll < Expr
        def __render__
          {match_all: {}}
        end
      end
    end
  end
end
