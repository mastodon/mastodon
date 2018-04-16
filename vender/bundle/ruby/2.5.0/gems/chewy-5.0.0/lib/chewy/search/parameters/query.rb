require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # A standard parameter storage, which updates `query` parameter
      # of the ES request.
      #
      # @example
      #   PlacesIndex.query(match: {name: 'Moscow'})
      #   # => <PlacesIndex::Query {..., :body=>{:query=>{:match=>{:name=>"Moscow"}}}}>
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-query.html
      # @see Chewy::Search::Parameters::QueryStorage
      class Query < Storage
        include QueryStorage
      end
    end
  end
end
