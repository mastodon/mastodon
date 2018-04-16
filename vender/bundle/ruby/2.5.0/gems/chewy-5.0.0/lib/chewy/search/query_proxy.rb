module Chewy
  module Search
    # This specialized proxy class is used to provide an ability
    # of `query`, `filter`, `post_filter` parameters additional
    # modification.
    #
    # @see Chewy::Search::Parameters::Query
    # @see Chewy::Search::Parameters::Filter
    # @see Chewy::Search::Parameters::PostFilter
    # @see Chewy::Search::Parameters::QueryStorage
    class QueryProxy
      # @param parameter_name [Symbol] modified parameter name
      # @param request [Chewy::Search::Request] request instance for modification
      def initialize(parameter_name, request)
        @parameter_name = parameter_name
        @request = request
      end

      # @!method must(query_hash = nil, &block)
      #   Executes {Chewy::Search::Parameters::QueryStorage#must} in the scope
      #   of newly created request object.
      #
      #   @see Chewy::Search::Parameters::QueryStorage#must
      #   @return [Chewy::Search::Request]
      #
      #   @overload must(query_hash)
      #     If pure hash is passed it is added to `must` array of the bool query.
      #
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       PlacesIndex.query.must(match: {name: 'Moscow'}).query.must(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param query_hash [Hash] pure query hash
      #
      #   @overload must
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       PlacesIndex.query.must { match name: 'Moscow' }.query.must { match name: 'London' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @yield the block is processed by `elasticsearch-dsl` gem
      #
      # @!method should(query_hash = nil, &block)
      #   Executes {Chewy::Search::Parameters::QueryStorage#should} in the scope
      #   of newly created request object.
      #
      #   @see Chewy::Search::Parameters::QueryStorage#should
      #   @return [Chewy::Search::Request]
      #
      #   @overload should(query_hash)
      #     If pure hash is passed it is added to `should` array of the bool query.
      #
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       PlacesIndex.query.should(match: {name: 'Moscow'}).query.should(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :should=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param query_hash [Hash] pure query hash
      #
      #   @overload should
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       PlacesIndex.query.should { match name: 'Moscow' }.query.should { match name: 'London' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :should=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @yield the block is processed by `elasticsearch-dsl` gem
      #
      # @!method must_not(query_hash = nil, &block)
      #   Executes {Chewy::Search::Parameters::QueryStorage#must_not} in the scope
      #   of newly created request object.
      #
      #   @see Chewy::Search::Parameters::QueryStorage#must_not
      #   @return [Chewy::Search::Request]
      #
      #   @overload must_not(query_hash)
      #     If pure hash is passed it is added to `must_not` array of the bool query.
      #
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       PlacesIndex.query.must_not(match: {name: 'Moscow'}).query.must_not(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must_not=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param query_hash [Hash] pure query hash
      #
      #   @overload must_not
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       PlacesIndex.query.must_not { match name: 'Moscow' }.query.must_not { match name: 'London' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must_not=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @yield the block is processed by `elasticsearch-dsl` gem
      %i[must should must_not].each do |method|
        define_method method do |query_hash = nil, &block|
          raise ArgumentError, "Please provide a parameter or a block to `#{method}`" unless query_hash || block
          @request.send(:modify, @parameter_name) { send(method, block || query_hash) }
        end
      end

      # @!method and(query_hash_or_scope = nil, &block)
      #   Executes {Chewy::Search::Parameters::QueryStorage#and} in the scope
      #   of newly created request object.
      #
      #   @see Chewy::Search::Parameters::QueryStorage#and
      #   @return [Chewy::Search::Request]
      #
      #   @overload and(query_hash)
      #     If pure hash is passed, the current root `bool` query and
      #     the passed one are joined into a single `must` array of the
      #     new root query.
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       scope = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope.query.and(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must=>[{:bool=>{:must_not=>{:match=>{:name=>"Moscow"}}}}, {:match=>{:name=>"London"}}]}}}}>
      #       scope = PlacesIndex.query(match: {name: 'Moscow'})
      #       scope.query.and(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param query_hash [Hash] pure query hash
      #
      #   @overload and(scope)
      #     If a scope is passed, the appropriate parameter storage value
      #     will be extracted from it and used as a second query.
      #     @example
      #       scope1 = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope2 = PlacesIndex.query(match: {name: 'London'})
      #       scope1.query.and(scope2)
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must=>[{:bool=>{:must_not=>{:match=>{:name=>"Moscow"}}}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param scope [Chewy::Search::Request] other scope
      #
      #   @overload and
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       scope = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope.query.and { match name: 'London' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must=>[{:bool=>{:must_not=>{:match=>{:name=>"Moscow"}}}}, {:match=>{:name=>"London"}}]}}}}>
      #     @yield the block is processed by `elasticsearch-dsl` gem
      #
      # @!method or(query_hash_or_scope = nil, &block)
      #   Executes {Chewy::Search::Parameters::QueryStorage#or} in the scope
      #   of newly created request object.
      #
      #   @see Chewy::Search::Parameters::QueryStorage#or
      #   @return [Chewy::Search::Request]
      #
      #   @overload or(query_hash)
      #     If pure hash is passed, the current root `bool` query and
      #     the passed one are joined into a single `should` array of the
      #     new root query.
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       scope = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope.query.or(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :should=>[{:bool=>{:must_not=>{:match=>{:name=>"Moscow"}}}}, {:match=>{:name=>"London"}}]}}}}>
      #       scope = PlacesIndex.query(match: {name: 'Moscow'})
      #       scope.query.or(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :should=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param query_hash [Hash] pure query hash
      #
      #   @overload or(scope)
      #     If a scope is passed, the appropriate parameter storage value
      #     will be extracted from it and used as a second query.
      #     @example
      #       scope1 = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope2 = PlacesIndex.query(match: {name: 'London'})
      #       scope1.query.or(scope2)
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :should=>[{:bool=>{:must_not=>{:match=>{:name=>"Moscow"}}}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param scope [Chewy::Search::Request] other scope
      #
      #   @overload or
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       scope = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope.query.or { match name: 'London' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :should=>[{:bool=>{:must_not=>{:match=>{:name=>"Moscow"}}}}, {:match=>{:name=>"London"}}]}}}}>
      #     @yield the block is processed by `elasticsearch-dsl` gem
      #
      # @!method not(query_hash_or_scope = nil, &block)
      #   Executes {Chewy::Search::Parameters::QueryStorage#not} in the scope
      #   of newly created request object.
      #   The only difference from {#must_not} is that is accepts another scope additionally.
      #
      #   @see Chewy::Search::Parameters::QueryStorage#not
      #   @return [Chewy::Search::Request]
      #
      #   @overload not(query_hash)
      #     If pure hash is passed it is added to `must_not` array of the bool query.
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       scope = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope.query.not(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must_not=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param query_hash [Hash] pure query hash
      #
      #   @overload not(scope)
      #     If a scope is passed, the appropriate parameter storage value
      #     will be extracted from it and used as a second query.
      #     @example
      #       scope1 = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope2 = PlacesIndex.query(match: {name: 'London'})
      #       scope1.query.not(scope2)
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must_not=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @param scope [Chewy::Search::Request] other scope
      #
      #   @overload not
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       scope = PlacesIndex.query.must_not(match: {name: 'Moscow'})
      #       scope.query.not { match name: 'London' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :must_not=>[{:match=>{:name=>"Moscow"}}, {:match=>{:name=>"London"}}]}}}}>
      #     @yield the block is processed by `elasticsearch-dsl` gem
      %i[and or not].each do |method|
        define_method method do |query_hash_or_scope = nil, &block|
          raise ArgumentError, "Please provide a parameter or a block to `#{method}`" unless query_hash_or_scope || block
          query_hash_or_scope = query_hash_or_scope.parameters[@parameter_name].value if !block && query_hash_or_scope.is_a?(Chewy::Search::Request)
          @request.send(:modify, @parameter_name) { send(method, block || query_hash_or_scope) }
        end
      end

      # Executes {Chewy::Search::Parameters::QueryStorage#minimum_should_match} in the scope
      # of newly created request object.
      #
      # @see Chewy::Search::Parameters::QueryStorage#minimum_should_match
      # @param value [String, Integer, nil]
      # @return [Chewy::Search::Request]
      def minimum_should_match(value)
        @request.send(:modify, @parameter_name) { minimum_should_match(value) }
      end
    end
  end
end
