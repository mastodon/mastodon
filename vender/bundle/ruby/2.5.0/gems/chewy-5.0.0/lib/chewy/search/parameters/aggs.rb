require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Just a standard hash storage. Nothing to see here.
      #
      # @see Chewy::Search::Parameters::HashStorage
      # @see Chewy::Search::Request#aggregations
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html
      class Aggs < Storage
        include HashStorage
      end
    end
  end
end
