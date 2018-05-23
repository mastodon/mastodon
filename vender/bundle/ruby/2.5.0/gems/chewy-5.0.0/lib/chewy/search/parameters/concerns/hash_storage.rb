module Chewy
  module Search
    class Parameters
      # Stores hashes with stringified keys.
      module HashStorage
        # Simply merges two value hashes on update
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [{String, Symbol => Object}] any acceptable storage value
        # @return [{String => Object}] updated value
        def update!(other_value)
          value.merge!(normalize(other_value))
        end

      private

        def normalize(value)
          (value || {}).stringify_keys
        end
      end
    end
  end
end
