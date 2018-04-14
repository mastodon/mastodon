module Chewy
  module Search
    class Parameters
      # Stores value as an array of strings.
      module StringArrayStorage
        # Unions two arrays.
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [String, Symbol, Array<String, Symbol>] any acceptable storage value
        # @return [Array<String, Symbol>] updated value
        def update!(other_value)
          @value = value | normalize(other_value)
        end

      private

        def normalize(value)
          Array.wrap(value).flatten(1).map(&:to_s).reject(&:blank?)
        end
      end
    end
  end
end
