module Chewy
  class Query
    module Nodes
      class Base
        def render
          raise NotImplementedError
        end

        def eql?(other)
          other.is_a?(self.class) && instance_variables.all? do |ivar|
            instance_variable_get(ivar).eql? other.instance_variable_get(ivar)
          end
        end
      end
    end
  end
end
