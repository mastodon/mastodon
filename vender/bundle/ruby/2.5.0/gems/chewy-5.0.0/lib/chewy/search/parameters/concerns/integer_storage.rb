module Chewy
  module Search
    class Parameters
      # Just a simple value storage, all the values are coerced to integer.
      module IntegerStorage
      private

        def normalize(value)
          Integer(value) if value
        end
      end
    end
  end
end
