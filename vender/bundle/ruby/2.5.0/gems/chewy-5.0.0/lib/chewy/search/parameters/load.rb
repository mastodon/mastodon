require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Acts like standard hash storage, with one exception:
      # all the keys are deeply symbolized for convenience.
      #
      # @see Chewy::Search::Request#load
      # @see Chewy::Search::Loader
      class Load < Storage
        # Simply merges two value hashes on update
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [{String, Symbol => Object}] any acceptable storage value
        # @return [{Symbol => Object}] updated value
        def update!(other_value)
          value.merge!(normalize(other_value))
        end

        # Doesn't render anythig, has specific handling logic.
        def render; end

      private

        def normalize(value)
          (value || {}).deep_symbolize_keys
        end
      end
    end
  end
end
