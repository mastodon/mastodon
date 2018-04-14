require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Just a standard boolean storage, nothing to see here.
      #
      # @see Chewy::Search::Parameters::BoolStorage
      # @see Chewy::Search::Request#explain
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-explain.html
      class Explain < Storage
        include BoolStorage
      end
    end
  end
end
