require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Just a standard hash storage. Nothing to see here.
      #
      # @see Chewy::Search::Parameters::HashStorage
      # @see Chewy::Search::Request#highlight
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-highlighting.html
      class Highlight < Storage
        include HashStorage
      end
    end
  end
end
