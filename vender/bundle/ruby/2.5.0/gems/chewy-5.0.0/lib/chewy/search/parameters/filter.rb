require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # This parameter storage doesn't have its own parameter at the
      # ES request body. Instead, it is embedded to the root `bool`
      # query of the `query` request parameter. Some additional query
      # reduction is performed in case of only several `must` filters
      # presence.
      #
      # @example
      #   scope = PlacesIndex.filter(term: {name: 'Moscow'})
      #   # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{:filter=>{:term=>{:name=>"Moscow"}}}}}}>
      #   scope.query(match: {name: 'London'})
      #   # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #   #      :must=>{:match=>{:name=>"London"}},
      #   #      :filter=>{:term=>{:name=>"Moscow"}}}}}}>
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-filter-context.html
      # @see Chewy::Search::Parameters::QueryStorage
      class Filter < Storage
        include QueryStorage

        # Even more reduction added here, we don't need to wrap with
        # `bool` query consists on `must` only.
        #
        # @see Chewy::Search::Parameters::Storage#render
        # @return [{Symbol => Hash}]
        def render
          rendered_bool = filter_query(value.query)
          {self.class.param_name => rendered_bool} if rendered_bool.present?
        end

      private

        def filter_query(value)
          bool = value[:bool] if value
          if bool && bool[:must].present? && bool[:should].blank? && bool[:must_not].blank?
            bool[:must]
          else
            value
          end
        end
      end
    end
  end
end
