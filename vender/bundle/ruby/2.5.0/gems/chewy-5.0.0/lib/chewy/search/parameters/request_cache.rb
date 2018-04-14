require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Stores boolean value, but has 3 states: `true`, `false` and `nil`.
      #
      # @see Chewy::Search::Request#request_cache
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/shard-request-cache.html#_enabling_and_disabling_caching_per_request
      class RequestCache < Storage
        # We don't want to render `nil`, but render `true` and `false` values.
        #
        # @see Chewy::Search::Parameters::Storage#render
        # @return [{Symbol => Object}, nil]
        def render
          {self.class.param_name => value} unless value.nil?
        end

      private

        def normalize(value)
          !!value unless value.nil?
        end
      end
    end
  end
end
