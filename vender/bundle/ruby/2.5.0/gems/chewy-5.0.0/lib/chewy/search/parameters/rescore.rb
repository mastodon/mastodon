require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Stores data as an array of hashes, exactly the same way
      # ES requires `rescore` to be provided.
      #
      # @see Chewy::Search::Request#rescore
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-rescore.html
      class Rescore < Storage
        # Adds new data to the existing data array.
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [Hash, Array<Hash>] any acceptable storage value
        # @return [Array<Hash>] updated value
        def update!(other_value)
          @value = value | normalize(other_value)
        end

      private

        def normalize(value)
          Array.wrap(value).flatten(1).reject(&:blank?)
        end
      end
    end
  end
end
