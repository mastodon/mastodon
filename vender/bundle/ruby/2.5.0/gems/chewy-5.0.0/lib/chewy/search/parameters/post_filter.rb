require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # A standard parameter storage, which updates `post_filter` parameter
      # of the ES request.
      #
      # @example
      #   PlacesIndex.post_filter(match: {name: 'Moscow'})
      #   # => <PlacesIndex::Query {..., :body=>{:post_filter=>{:match=>{:name=>"Moscow"}}}}>
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-post-filter.html
      # @see Chewy::Search::Parameters::QueryStorage
      class PostFilter < Storage
        include QueryStorage
      end
    end
  end
end
