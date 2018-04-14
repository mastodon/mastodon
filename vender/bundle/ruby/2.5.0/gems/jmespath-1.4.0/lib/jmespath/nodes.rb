module JMESPath
  # @api private
  module Nodes
    class Node
      def visit(value)
      end

      def hash_like?(value)
        Hash === value || Struct === value
      end

      def optimize
        self
      end

      def chains_with?(other)
        false
      end
    end
    
    require  'jmespath/nodes/subexpression'
    require  'jmespath/nodes/and'
    require  'jmespath/nodes/comparator'
    require  'jmespath/nodes/comparator'
    require  'jmespath/nodes/condition'
    require  'jmespath/nodes/current'
    require  'jmespath/nodes/expression'
    require  'jmespath/nodes/field'
    require  'jmespath/nodes/flatten'
    require  'jmespath/nodes/function'
    require  'jmespath/nodes/index'
    require  'jmespath/nodes/literal'
    require  'jmespath/nodes/multi_select_hash'
    require  'jmespath/nodes/multi_select_list'
    require  'jmespath/nodes/not'
    require  'jmespath/nodes/or'
    require  'jmespath/nodes/pipe'
    require  'jmespath/nodes/projection'
    require  'jmespath/nodes/projection'
    require  'jmespath/nodes/projection'
    require  'jmespath/nodes/slice'


  end
end
