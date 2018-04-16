require 'chewy/query/nodes/has_relation'

module Chewy
  class Query
    module Nodes
      class HasParent < HasRelation
      private

        def _relation
          :has_parent
        end
      end
    end
  end
end
