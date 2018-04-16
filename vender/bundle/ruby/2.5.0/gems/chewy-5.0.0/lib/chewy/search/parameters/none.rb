require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Just a standard boolean storage, except the rendering logic.
      #
      # @see Chewy::Search::Parameters::BoolStorage
      # @see Chewy::Search::Request#none
      # @see https://en.wikipedia.org/wiki/Null_Object_pattern
      class None < Storage
        include BoolStorage

        # Renders `match_none` query if the values is set to true.
        # Well, we can't really use match none because we need to support
        # ES2, so we are simulating it with `match_all` negation.
        #
        # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-all-query.html#query-dsl-match-none-query
        # @see Chewy::Search::Request
        # @see Chewy::Search::Request#response
        def render
          {query: {bool: {filter: {bool: {must_not: {match_all: {}}}}}}} if value.present?
        end
      end
    end
  end
end
