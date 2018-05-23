module Chewy
  module Search
    class Parameters
      # Stores a boolean value. Any passed value is coerced to
      # a boolean value.
      module BoolStorage
        # Performs values disjunction on update.
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [true, false, Object] any acceptable storage value
        # @return [true, false] updated value
        def update!(other_value)
          replace!(value || normalize(other_value))
        end

      private

        def normalize(value)
          !!value
        end
      end
    end
  end
end
