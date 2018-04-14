require 'chewy/query/nodes/has_relation'

module Chewy
  class Query
    module Nodes
      class HasChild < HasRelation
      private

        def _relation
          :has_child
        end
      end
    end
  end
end
