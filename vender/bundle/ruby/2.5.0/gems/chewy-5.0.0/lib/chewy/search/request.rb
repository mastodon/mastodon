module Chewy
  module Search
    # The main requset DSL class. Supports multiple index requests.
    # Supports ES2 and ES5 search API and query DSL.
    #
    # @note The class tries to be as immutable as possible,
    #   so most of the methods return a new instance of the class.
    # @see Chewy::Search
    # @example
    #   scope = Chewy::Search::Request.new(PlacesIndex)
    #   # => <Chewy::Search::Request {:index=>["places"], :type=>["city", "country"]}>
    #   scope.limit(20)
    #   # => <Chewy::Search::Request {:index=>["places"], :type=>["city", "country"], :body=>{:size=>20}}>
    #   scope.order(:name).offset(10)
    #   # => <Chewy::Search::Request {:index=>["places"], :type=>["city", "country"], :body=>{:sort=>["name"], :from=>10}}>
    class Request
      include Enumerable
      include Scoping
      include Scrolling
      UNDEFINED = Class.new.freeze
      EVERFIELDS = %w[_index _type _id _parent].freeze
      DELEGATED_METHODS = %i[
        query filter post_filter order reorder docvalue_fields
        track_scores request_cache explain version profile
        search_type preference limit offset terminate_after
        timeout min_score source stored_fields search_after
        load script_fields suggest aggs aggregations none
        indices_boost rescore highlight total total_count
        total_entries types delete_all count exists? exist? find pluck
        scroll_batches scroll_hits scroll_results scroll_wrappers
      ].to_set.freeze
      DEFAULT_BATCH_SIZE = 1000
      DEFAULT_PLUCK_BATCH_SIZE = 10_000
      DEFAULT_SCROLL = '1m'.freeze
      # An array of storage names that are modifying returned fields in hits
      FIELD_STORAGES = %i[
        source docvalue_fields script_fields stored_fields
      ].freeze
      # An array of storage names that are not related to hits at all.
      EXTRA_STORAGES = %i[aggs suggest].freeze
      # An array of storage names that are changing the returned hist collection in any way.
      WHERE_STORAGES = %i[
        query filter post_filter none types min_score rescore indices_boost
      ].freeze

      delegate :hits, :wrappers, :objects, :records, :documents,
        :object_hash, :record_hash, :document_hash,
        :total, :max_score, :took, :timed_out?, to: :response
      delegate :each, :size, :to_a, :[], to: :wrappers
      alias_method :to_ary, :to_a
      alias_method :total_count, :total
      alias_method :total_entries, :total

      attr_reader :_indexes, :_types

      # The class is initialized with the list of chewy indexes and/or
      # types, which are later used to compose requests.
      #
      # @example
      #   Chewy::Search::Request.new(PlacesIndex)
      #   # => <Chewy::Search::Request {:index=>["places"], :type=>["city", "country"]}>
      #   Chewy::Search::Request.new(PlacesIndex::City)
      #   # => <Chewy::Search::Request {:index=>["places"], :type=>["city"]}>
      #   Chewy::Search::Request.new(UsersIndex, PlacesIndex::City)
      #   # => <Chewy::Search::Request {:index=>["users", "places"], :type=>["city", "user"]}>
      # @param indexes_or_types [Array<Chewy::Index, Chewy::Type>] indexes and types in any combinations
      def initialize(*indexes_or_types)
        @_types = indexes_or_types.select { |klass| klass < Chewy::Type }
        @_indexes = indexes_or_types.select { |klass| klass < Chewy::Index }
        @_types |= @_indexes.flat_map(&:types)
        @_indexes |= @_types.map(&:index)
      end

      # Underlying parameter storage collection.
      #
      # @return [Chewy::Search::Parameters]
      def parameters
        @parameters ||= Parameters.new
      end

      # Compare two scopes or scope with a collection of wrappers.
      # If other is a collection it performs the request to fetch
      # data from ES.
      #
      # @example
      #   PlacesIndex.limit(10) == PlacesIndex.limit(10) # => true
      #   PlacesIndex.limit(10) == PlacesIndex.limit(10).to_a # => true
      #   PlacesIndex.limit(10) == PlacesIndex.limit(10).objects # => true
      #
      #   PlacesIndex.limit(10) == UsersIndex.limit(10) # => false
      #   PlacesIndex.limit(10) == UsersIndex.limit(10).to_a # => false
      #
      #   PlacesIndex.limit(10) == Object.new # => false
      # @param other [Object] any object
      # @return [true, false] the result of comparison
      def ==(other)
        super || other.is_a?(Chewy::Search::Request) ? compare_internals(other) : to_a == other
      end

      # Access to ES response wrappers providing useful methods such as
      # {Chewy::Search::Response#total} or {Chewy::Search::Response#max_score}.
      #
      # @see Chewy::Search::Response
      # @return [Chewy::Search::Response] a response object instance
      def response
        @response ||= Response.new(perform, loader, collection_paginator)
      end

      # ES request body
      #
      # @return [Hash] request body
      def render
        @render ||= render_base.merge(parameters.render)
      end

      # Includes the class name and the result of rendering.
      #
      # @return [String]
      def inspect
        "<#{self.class} #{render}>"
      end

      # @!group Chainable request modificators

      # @!method query(query_hash=nil, &block)
      #   Adds `quer` parameter to the search request body.
      #
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-query.html
      #   @see Chewy::Search::Parameters::Query
      #   @return [Chewy::Search::Request, Chewy::Search::QueryProxy]
      #
      #   @overload query(query_hash)
      #     If pure hash is passed it goes straight to the `quer` parameter storage.
      #     Acts exactly the same way as {Chewy::Search::QueryProxy#must}.
      #
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       PlacesIndex.query(match: {name: 'Moscow'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:match=>{:name=>"Moscow"}}}}>
      #     @param query_hash [Hash] pure query hash
      #     @return [Chewy::Search::Request]
      #
      #   @overload query
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #     Acts exactly the same way as {Chewy::Search::QueryProxy#must} with a block.
      #
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       PlacesIndex.query { match name: 'Moscow' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:match=>{:name=>"Moscow"}}}}>
      #     @yield the block is processed by `elasticsearch-ds` gem
      #     @return [Chewy::Search::Request]
      #
      #   @overload query
      #     If nothing is passed it returns a proxy for additional
      #     parameter manipulations.
      #
      #     @see Chewy::Search::QueryProxy
      #     @example
      #       PlacesIndex.query.should(match: {name: 'Moscow'}).query.not(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :should=>{:match=>{:name=>"Moscow"}},
      #       #      :must_not=>{:match=>{:name=>"London"}}}}}}>
      #     @return [Chewy::Search::QueryProxy]
      #
      # @!method filter(query_hash=nil, &block)
      #   Adds `filte` context of the `quer` parameter at the
      #   search request body.
      #
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-filter-context.html
      #   @see Chewy::Search::Parameters::Filter
      #   @return [Chewy::Search::Request, Chewy::Search::QueryProxy]
      #
      #   @overload filter(query_hash)
      #     If pure hash is passed it goes straight to the `filte` context of the `quer` parameter storage.
      #     Acts exactly the same way as {Chewy::Search::QueryProxy#must}.
      #
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       PlacesIndex.filter(match: {name: 'Moscow'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :filter=>{:match=>{:name=>"Moscow"}}}}}}>
      #     @param query_hash [Hash] pure query hash
      #     @return [Chewy::Search::Request]
      #
      #   @overload filter
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #     Acts exactly the same way as {Chewy::Search::QueryProxy#must} with a block.
      #
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       PlacesIndex.filter { match name: 'Moscow' }
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :filter=>{:match=>{:name=>"Moscow"}}}}}}>
      #     @yield the block is processed by `elasticsearch-ds` gem
      #     @return [Chewy::Search::Request]
      #
      #   @overload filter
      #     If nothing is passed it returns a proxy for additional
      #     parameter manipulations.
      #
      #     @see Chewy::Search::QueryProxy
      #     @example
      #       PlacesIndex.filter.should(match: {name: 'Moscow'}).filter.not(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #       #      :filter=>{:bool=>{:should=>{:match=>{:name=>"Moscow"}},
      #       #      :must_not=>{:match=>{:name=>"London"}}}}}}}}>
      #     @return [Chewy::Search::QueryProxy]
      #
      # @!method post_filter(query_hash=nil, &block)
      #   Adds `post_filter` parameter to the search request body.
      #
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-post-filter.html
      #   @see Chewy::Search::Parameters::PostFilter
      #   @return [Chewy::Search::Request, Chewy::Search::QueryProxy]
      #
      #   @overload post_filter(query_hash)
      #     If pure hash is passed it goes straight to the `post_filter` parameter storage.
      #     Acts exactly the same way as {Chewy::Search::QueryProxy#must}.
      #
      #     @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
      #     @example
      #       PlacesIndex.post_filter(match: {name: 'Moscow'})
      #       # => <PlacesIndex::Query {..., :body=>{:post_filter=>{:match=>{:name=>"Moscow"}}}}>
      #     @param query_hash [Hash] pure query hash
      #     @return [Chewy::Search::Request]
      #
      #   @overload post_filter
      #     If block is passed instead of a pure hash, `elasticsearch-dsl"
      #     gem will be used to process it.
      #     Acts exactly the same way as {Chewy::Search::QueryProxy#must} with a block.
      #
      #     @see https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl
      #     @example
      #       PlacesIndex.post_filter { match name: 'Moscow' }
      #       # => <PlacesIndex::Query {..., :body=>{:post_filter=>{:match=>{:name=>"Moscow"}}}}>
      #     @yield the block is processed by `elasticsearch-ds` gem
      #     @return [Chewy::Search::Request]
      #
      #   @overload post_filter
      #     If nothing is passed it returns a proxy for additional
      #     parameter manipulations.
      #
      #     @see Chewy::Search::QueryProxy
      #     @example
      #       PlacesIndex.post_filter.should(match: {name: 'Moscow'}).post_filter.not(match: {name: 'London'})
      #       # => <PlacesIndex::Query {..., :body=>{:post_filter=>{:bool=>{
      #       #      :should=>{:match=>{:name=>"Moscow"}},
      #       #      :must_not=>{:match=>{:name=>"London"}}}}}}>
      #     @return [Chewy::Search::QueryProxy]
      %i[query filter post_filter].each do |name|
        define_method name do |query_hash = UNDEFINED, &block|
          if block || query_hash != UNDEFINED
            modify(name) { must(block || query_hash) }
          else
            Chewy::Search::QueryProxy.new(name, self)
          end
        end
      end

      # @!method order(*values)
      #   Modifies `sort` request parameter. Updates the storage on every call.
      #
      #   @example
      #     PlacesIndex.order(:name, population: {order: :asc}).order(:coordinates)
      #     # => <PlacesIndex::Query {..., :body=>{:sort=>["name", {"population"=>{:order=>:asc}}, "coordinates"]}}>
      #   @see Chewy::Search::Parameters::Order
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-sort.html
      #   @param values [Array<Hash, String, Symbol>] sort fields and options
      #   @return [Chewy::Search::Request]
      #
      # @!method docvalue_fields(*values)
      #   Modifies `docvalue_fields` request parameter. Updates the storage on every call.
      #
      #   @example
      #     PlacesIndex.docvalue_fields(:name).docvalue_fields(:population, :coordinates)
      #     # => <PlacesIndex::Query {..., :body=>{:docvalue_fields=>["name", "population", "coordinates"]}}>
      #   @see Chewy::Search::Parameters::DocvalueFields
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-docvalue-fields.html
      #   @param values [Array<String, Symbol>] field names
      #   @return [Chewy::Search::Request]
      #
      # @!method types(*values)
      #   Modifies `types` request parameter. Updates the storage on every call.
      #   Constrains types passed on the request initialization.
      #
      #   @example
      #     PlacesIndex.types(:city).types(:unexistent)
      #     # => <PlacesIndex::Query {:index=>["places"], :type=>["city"]}>
      #   @see Chewy::Search::Parameters::Types
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html
      #   @param values [Array<String, Symbol>] type names
      #   @return [Chewy::Search::Request]
      %i[order docvalue_fields types].each do |name|
        define_method name do |value, *values|
          modify(name) { update!([value, *values]) }
        end
      end

      # @overload reorder(*values)
      #   Replaces the value of the `sort` parameter with the provided value.
      #
      #   @example
      #     PlacesIndex.order(:name, population: {order: :asc}).reorder(:coordinates)
      #     # => <PlacesIndex::Query {..., :body=>{:sort=>["coordinates"]}}>
      #   @see Chewy::Search::Parameters::Order
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-sort.html
      #   @param values [Array<Hash, String, Symbol>] sort fields and options
      #   @return [Chewy::Search::Request]
      def reorder(value, *values)
        modify(:order) { replace!([value, *values]) }
      end

      # @!method track_scores(value = true)
      #   Replaces the value of the `track_scores` parameter with the provided value.
      #
      #   @example
      #     PlacesIndex.track_scores
      #     # => <PlacesIndex::Query {..., :body=>{:track_scores=>true}}>
      #     PlacesIndex.track_scores.track_scores(false)
      #     # => <PlacesIndex::Query {:index=>["places"], :type=>["city", "country"]}>
      #   @see Chewy::Search::Parameters::TrackScores
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-sort.html#_track_scores
      #   @param value [true, false]
      #   @return [Chewy::Search::Request]
      #
      # @!method explain(value = true)
      #   Replaces the value of the `explain` parameter with the provided value.
      #
      #   @example
      #     PlacesIndex.explain
      #     # => <PlacesIndex::Query {..., :body=>{:explain=>true}}>
      #     PlacesIndex.explain.explain(false)
      #     # => <PlacesIndex::Query {:index=>["places"], :type=>["city", "country"]}>
      #   @see Chewy::Search::Parameters::Explain
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-explain.html
      #   @param value [true, false]
      #   @return [Chewy::Search::Request]
      #
      # @!method version(value = true)
      #   Replaces the value of the `version` parameter with the provided value.
      #
      #   @example
      #     PlacesIndex.version
      #     # => <PlacesIndex::Query {..., :body=>{:version=>true}}>
      #     PlacesIndex.version.version(false)
      #     # => <PlacesIndex::Query {:index=>["places"], :type=>["city", "country"]}>
      #   @see Chewy::Search::Parameters::Version
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-version.html
      #   @param value [true, false]
      #   @return [Chewy::Search::Request]
      #
      # @!method profile(value = true)
      #   Replaces the value of the `profile` parameter with the provided value.
      #
      #   @example
      #     PlacesIndex.profile
      #     # => <PlacesIndex::Query {..., :body=>{:profile=>true}}>
      #     PlacesIndex.profile.profile(false)
      #     # => <PlacesIndex::Query {:index=>["places"], :type=>["city", "country"]}>
      #   @see Chewy::Search::Parameters::Profile
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-profile.html
      #   @param value [true, false]
      #   @return [Chewy::Search::Request]
      #
      # @!method none(value = true)
      #   Enables `NullObject` pattern for the request, doesn't perform the
      #   request, `#hits` are empty, `#total` is 0, etc.
      #
      #   @example
      #     PlacesIndex.none.to_a
      #     # => []
      #     PlacesIndex.none.total
      #     # => 0
      #   @see Chewy::Search::Parameters::None
      #   @see https://en.wikipedia.org/wiki/Null_Object_pattern
      #   @param value [true, false]
      #   @return [Chewy::Search::Request]
      %i[track_scores explain version profile none].each do |name|
        define_method name do |value = true|
          modify(name) { replace!(value) }
        end
      end

      # @!method request_cache(value)
      #   Replaces the value of the `request_cache` parameter with the provided value.
      #   Unlike other boolean fields, the value have to be specified explicitly
      #   since it overrides the index-level setting.
      #
      #   @example
      #     PlacesIndex.request_cache(true)
      #     # => <PlacesIndex::Query {..., :body=>{:request_cache=>true}}>
      #     PlacesIndex.request_cache(false)
      #     # => <PlacesIndex::Query {..., :body=>{:request_cache=>false}}>
      #   @see Chewy::Search::Parameters::RequestCache
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/shard-request-cache.html#_enabling_and_disabling_caching_per_request
      #   @param value [true, false, nil]
      #   @return [Chewy::Search::Request]
      #
      # @!method search_type(value)
      #   Replaces the value of the `search_type` request part.
      #
      #   @example
      #     PlacesIndex.search_type(:dfs_query_then_fetch)
      #     # => <PlacesIndex::Query {..., :body=>{:search_type=>"dfs_query_then_fetch"}}>
      #   @see Chewy::Search::Parameters::SearchType
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-search-type.html
      #   @param value [String, Symbol]
      #   @return [Chewy::Search::Request]
      #
      # @!method preference(value)
      #   Replaces the value of the `preference` request part.
      #
      #   @example
      #     PlacesIndex.preference(:_primary_first)
      #     # => <PlacesIndex::Query {..., :body=>{:preference=>"_primary_first"}}>
      #   @see Chewy::Search::Parameters::Preference
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-preference.html
      #   @param value [String, Symbol]
      #   @return [Chewy::Search::Request]
      #
      # @!method timeout(value)
      #   Replaces the value of the `timeout` request part.
      #
      #   @example
      #     PlacesIndex.timeout('1m')
      #     <PlacesIndex::Query {..., :body=>{:timeout=>"1m"}}>
      #   @see Chewy::Search::Parameters::Timeout
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/common-options.html#time-units
      #   @param value [String, Symbol]
      #   @return [Chewy::Search::Request]
      #
      # @!method limit(value)
      #   Replaces the value of the `size` request part.
      #
      #   @example
      #     PlacesIndex.limit(10)
      #     <PlacesIndex::Query {..., :body=>{:size=>10}}>
      #   @see Chewy::Search::Parameters::Limit
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-from-size.html
      #   @param value [String, Integer]
      #   @return [Chewy::Search::Request]
      #
      # @!method offset(value)
      #   Replaces the value of the `from` request part.
      #
      #   @example
      #     PlacesIndex.offset(10)
      #     <PlacesIndex::Query {..., :body=>{:from=>10}}>
      #   @see Chewy::Search::Parameters::Offset
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-from-size.html
      #   @param value [String, Integer]
      #   @return [Chewy::Search::Request]
      #
      # @!method terminate_after(value)
      #   Replaces the value of the `terminate_after` request part.
      #
      #   @example
      #     PlacesIndex.terminate_after(10)
      #     <PlacesIndex::Query {..., :body=>{:terminate_after=>10}}>
      #   @see Chewy::Search::Parameters::Offset
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-body.html
      #   @param value [String, Integer]
      #   @return [Chewy::Search::Request]
      #
      # @!method min_score(value)
      #   Replaces the value of the `min_score` request part.
      #
      #   @example
      #     PlacesIndex.min_score(2)
      #     <PlacesIndex::Query {..., :body=>{:min_score=>2.0}}>
      #   @see Chewy::Search::Parameters::Offset
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-min-score.html
      #   @param value [String, Integer, Float]
      #   @return [Chewy::Search::Request]
      %i[request_cache search_type preference timeout limit offset terminate_after min_score].each do |name|
        define_method name do |value|
          modify(name) { replace!(value) }
        end
      end

      # @!method source(*values)
      #   Updates `_source` request part. Accepts either an array
      #   of field names/templates or a hash with `includes` and `excludes`
      #   keys. Source also can be disabled entierly or enabled again.
      #
      #   @example
      #     PlacesIndex.source(:name).source(includes: [:popularity], excludes: :description)
      #     # => <PlacesIndex::Query {..., :body=>{:_source=>{:includes=>["name", "popularity"], :excludes=>["description"]}}}>
      #     PlacesIndex.source(false)
      #     # => <PlacesIndex::Query {..., :body=>{:_source=>false}}>
      #   @see Chewy::Search::Parameters::Source
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-source-filtering.html
      #   @param values [true, false, {Symbol => Array<String, Symbol>, String, Symbol}, Array<String, Symbol>, String, Symbol]
      #   @return [Chewy::Search::Request]
      #
      # @!method stored_fields(*values)
      #   Updates `stored_fields` request part. Accepts an array of field
      #   names. Can be entierly disabled and enabled back.
      #
      #   @example
      #     PlacesIndex.stored_fields(:name).stored_fields(:description)
      #     # => <PlacesIndex::Query {..., :body=>{:stored_fields=>["name", "description"]}}>
      #     PlacesIndex.stored_fields(false)
      #     # => <PlacesIndex::Query {..., :body=>{:stored_fields=>"_none_"}}>
      #   @see Chewy::Search::Parameters::StoredFields
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-stored-fields.html
      #   @param values [true, false, String, Symbol, Array<String, Symbol>]
      #   @return [Chewy::Search::Request]
      %i[source stored_fields].each do |name|
        define_method name do |value, *values|
          modify(name) { update!(values.empty? ? value : [value, *values]) }
        end
      end

      # @overload search_after(*values)
      # Replaces the storage value for `search_after` request part.
      #
      # @example
      #   PlacesIndex.search_after(42, 'Moscow').search_after('London')
      #   # => <PlacesIndex::Query {..., :body=>{:search_after=>["London"]}}>
      # @see Chewy::Search::Parameters::SearchAfter
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-search-after.html
      # @param value [Array, Object]
      # @return [Chewy::Search::Request]
      def search_after(value, *values)
        modify(:search_after) { replace!(values.empty? ? value : [value, *values]) }
      end

      # Stores ORM/ODM objects loading options. Options
      # might be define per-type or be global, depends on the adapter
      # loading implementation. Also, there are 2 loading options to select
      # or exclude types from loading: `only` and `except` respectively.
      # Options are updated on further method calls.
      #
      # @example
      #   PlaceIndex.load(only: 'city').load(scope: -> { active })
      # @see Chewy::Search::Loader
      # @see Chewy::Search::Response#objects
      # @see Chewy::Search::Scrolling#scroll_objects
      # @param options [Hash] adapter-specific loading options
      def load(options = nil)
        modify(:load) { update!(options) }
      end

      # @!method script_fields(value)
      #   Add a `script_fields` part to the request. Further
      #   call values are merged to the storage hash.
      #
      #   @example
      #     PlacesIndex
      #       .script_fields(field1: {script: {lang: 'painless', inline: 'some script here'}})
      #       .script_fields(field2: {script: {lang: 'painless', inline: 'some script here'}})
      #     # => <PlacesIndex::Query {..., :body=>{:script_fields=>{
      #     #      "field1"=>{:script=>{:lang=>"painless", :inline=>"some script here"}},
      #     #      "field2"=>{:script=>{:lang=>"painless", :inline=>"some script here"}}}}}>
      #   @see Chewy::Search::Parameters::ScriptFields
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-script-fields.html
      #   @param value [Hash]
      #   @return [Chewy::Search::Request]
      #
      # @!method indices_boost(value)
      #   Add an `indices_boost` part to the request. Further
      #   call values are merged to the storage hash.
      #
      #   @example
      #     PlacesIndex.indices_boost(index1: 1.2, index2: 1.3).indices_boost(index1: 1.5)
      #     # => <PlacesIndex::Query {..., :body=>{:indices_boost=>[{"index2"=>1.3}, {"index1"=>1.5}]}}>
      #   @see Chewy::Search::Parameters::IndicesBoost
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-index-boost.html
      #   @param value [{String, Symbol => String, Integer, Float}]
      #   @return [Chewy::Search::Request]
      #
      # @!method rescore(value)
      #   Add a `rescore` part to the request. Further
      #   call values are added to the storage array.
      #
      #   @example
      #     PlacesIndex.rescore(window_size: 100, query: {}).rescore(window_size: 200, query: {})
      #     # => <PlacesIndex::Query {..., :body=>{:rescore=>[{:window_size=>100, :query=>{}}, {:window_size=>200, :query=>{}}]}}>
      #   @see Chewy::Search::Parameters::Rescore
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-rescore.html
      #   @param value [Hash, Array<Hash>]
      #   @return [Chewy::Search::Request]
      #
      # @!method highlight(value)
      #   Add a `highlight` configuration to the request. Further
      #   call values are merged to the storage hash.
      #
      #   @example
      #     PlacesIndex
      #       .highlight(fields: {description: {type: 'plain'}})
      #       .highlight(pre_tags: ['<em>'], post_tags: ['</em>'])
      #     # => <PlacesIndex::Query {..., :body=>{:highlight=>{
      #     #      "fields"=>{:description=>{:type=>"plain"}},
      #     #      "pre_tags"=>["<em>"], "post_tags"=>["</em>"]}}}>
      #   @see Chewy::Search::Parameters::Highlight
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-highlighting.html
      #   @param value [Hash]
      #   @return [Chewy::Search::Request]
      %i[script_fields indices_boost rescore highlight].each do |name|
        define_method name do |value|
          modify(name) { update!(value) }
        end
      end

      # A dual-purpose method.
      #
      # @overload suggest(value)
      #   With the value provided it adds a new suggester
      #   to the suggestion hash.
      #
      #   @example
      #     PlacesIndex
      #       .suggest(names: {text: 'tring out Elasticsearch'})
      #       .suggest(descriptions: {text: 'some other text'})
      #     # => <PlacesIndex::Query {..., :body=>{:suggest=>{
      #     #      "names"=>{:text=>"tring out Elasticsearch"},
      #     #      "descriptions"=>{:text=>"some other text"}}}}>
      #   @see Chewy::Search::Parameters::Suggest
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-suggesters.html
      #   @param value [Hash]
      #   @return [Chewy::Search::Request]
      #
      # @overload suggest
      #   Without value provided, it performs the request and
      #   returns {Chewy::Search::Response#suggest} contents.
      #
      #   @example
      #     PlacesIndex.suggest(names: {text: 'tring out Elasticsearch'}).suggest
      #   @see Chewy::Search::Response#suggest
      #   @return [Hash]
      def suggest(value = UNDEFINED)
        if value == UNDEFINED
          response.suggest
        else
          modify(:suggest) { update!(value) }
        end
      end

      # A dual-purpose method.
      #
      # @overload aggs(value)
      #   With the value provided it adds a new aggregation
      #   to the aggregation hash.
      #
      #   @example
      #     PlacesIndex
      #       .aggs(avg_population: {avg: {field: :population}})
      #       .aggs(avg_age: {avg: {field: :age}})
      #     # => <PlacesIndex::Query {..., :body=>{:aggs=>{
      #     #      "avg_population"=>{:avg=>{:field=>:population}},
      #     #      "avg_age"=>{:avg=>{:field=>:age}}}}}>
      #   @see Chewy::Search::Parameters::Aggs
      #   @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html
      #   @param value [Hash]
      #   @return [Chewy::Search::Request]
      #
      # @overload aggs
      #   Without value provided, it performs the request and
      #   returns {Chewy::Search::Response#aggs} contents.
      #
      #   @example
      #     PlacesIndex.aggs(avg_population: {avg: {field: :population}}).aggs
      #   @see Chewy::Search::Response#aggs
      #   @return [Hash]
      def aggs(value = UNDEFINED)
        if value == UNDEFINED
          response.aggs
        else
          modify(:aggs) { update!(value) }
        end
      end
      alias_method :aggregations, :aggs

      # @!group Scopes manipulation

      # Merges 2 scopes by merging their parameters.
      #
      # @example
      #   scope1 = PlacesIndex.limit(10).offset(10)
      #   scope2 = PlacesIndex.limit(20)
      #   scope1.merge(scope2)
      #   # => <PlacesIndex::Query {..., :body=>{:size=>20, :from=>10}}>
      #   scope2.merge(scope1)
      #   # => <PlacesIndex::Query {..., :body=>{:size=>10, :from=>10}}>
      # @see Chewy::Search::Parameters#merge
      # @param other [Chewy::Search::Request] scope to merge
      # @return [Chewy::Search::Request] new scope
      def merge(other)
        chain { parameters.merge!(other.parameters) }
      end

      # @!method and(other)
      #   Takes `query`, `filter`, `post_filter` from the passed scope
      #   and performs {Chewy::Search::QueryProxy#and} operation for each
      #   of them. Unlike merge, every other parameter is kept unmerged
      #   (values from the first scope are used in the result scope).
      #
      #   @see Chewy::Search::QueryProxy#and
      #   @example
      #     scope1 = PlacesIndex.filter(term: {name: 'Moscow'}).query(match: {name: 'London'})
      #     scope2 = PlacesIndex.filter.not(term: {name: 'Berlin'}).query(match: {name: 'Washington'})
      #     scope1.and(scope2)
      #     # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #     #      :must=>[{:match=>{:name=>"London"}}, {:match=>{:name=>"Washington"}}],
      #     #      :filter=>{:bool=>{:must=>[{:term=>{:name=>"Moscow"}}, {:bool=>{:must_not=>{:term=>{:name=>"Berlin"}}}}]}}}}}}>
      #   @param other [Chewy::Search::Request] scope to merge
      #   @return [Chewy::Search::Request] new scope
      #
      # @!method or(other)
      #   Takes `query`, `filter`, `post_filter` from the passed scope
      #   and performs {Chewy::Search::QueryProxy#or} operation for each
      #   of them. Unlike merge, every other parameter is kept unmerged
      #   (values from the first scope are used in the result scope).
      #
      #   @see Chewy::Search::QueryProxy#or
      #   @example
      #     scope1 = PlacesIndex.filter(term: {name: 'Moscow'}).query(match: {name: 'London'})
      #     scope2 = PlacesIndex.filter.not(term: {name: 'Berlin'}).query(match: {name: 'Washington'})
      #     scope1.or(scope2)
      #     # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #     #      :should=>[{:match=>{:name=>"London"}}, {:match=>{:name=>"Washington"}}],
      #     #      :filter=>{:bool=>{:should=>[{:term=>{:name=>"Moscow"}}, {:bool=>{:must_not=>{:term=>{:name=>"Berlin"}}}}]}}}}}}>
      #   @param other [Chewy::Search::Request] scope to merge
      #   @return [Chewy::Search::Request] new scope
      #
      # @!method not(other)
      #   Takes `query`, `filter`, `post_filter` from the passed scope
      #   and performs {Chewy::Search::QueryProxy#not} operation for each
      #   of them. Unlike merge, every other parameter is kept unmerged
      #   (values from the first scope are used in the result scope).
      #
      #   @see Chewy::Search::QueryProxy#not
      #   @example
      #     scope1 = PlacesIndex.filter(term: {name: 'Moscow'}).query(match: {name: 'London'})
      #     scope2 = PlacesIndex.filter.not(term: {name: 'Berlin'}).query(match: {name: 'Washington'})
      #     scope1.not(scope2)
      #     # => <PlacesIndex::Query {..., :body=>{:query=>{:bool=>{
      #     #      :must=>{:match=>{:name=>"London"}}, :must_not=>{:match=>{:name=>"Washington"}},
      #     #      :filter=>{:bool=>{:must=>{:term=>{:name=>"Moscow"}}, :must_not=>{:bool=>{:must_not=>{:term=>{:name=>"Berlin"}}}}}}}}}}>
      #   @param other [Chewy::Search::Request] scope to merge
      #   @return [Chewy::Search::Request] new scope
      %i[and or not].each do |name|
        define_method name do |other|
          %i[query filter post_filter].inject(self) do |scope, parameter_name|
            scope.send(parameter_name).send(name, other.parameters[parameter_name].value)
          end
        end
      end

      # Returns a new scope containing only specified storages.
      #
      # @example
      #   PlacesIndex.limit(10).offset(10).order(:name).except(:offset, :order)
      #   # => <PlacesIndex::Query {..., :body=>{:size=>10}}>
      # @param values [Array<String, Symbol>]
      # @return [Chewy::Search::Request] new scope
      def only(*values)
        chain { parameters.only!(values.flatten(1)) }
      end

      # Returns a new scope containing all the storages except specified.
      #
      # @example
      #   PlacesIndex.limit(10).offset(10).order(:name).only(:offset, :order)
      #   # => <PlacesIndex::Query {..., :body=>{:from=>10, :sort=>["name"]}}>
      # @param values [Array<String, Symbol>]
      # @return [Chewy::Search::Request] new scope
      def except(*values)
        chain { parameters.except!(values.flatten(1)) }
      end

      # @!group Additional actions

      # Returns total count of hits for the request. If the request
      # was already performed - it uses the `total` value, otherwise
      # it executes a fast count request.
      #
      # @return [Integer] total hits count
      def count
        if performed?
          total
        else
          Chewy.client.count(only(WHERE_STORAGES).render)['count']
        end
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        0
      end

      # Checks if any of the document exist for this request. If
      # the request was already performed - it uses the `total`,
      # otherwise it executes a fast request to check existence.
      #
      # @return [true, false] wether hits exist or not
      def exists?
        if performed?
          total != 0
        else
          limit(0).terminate_after(1).total != 0
        end
      end
      alias_method :exist?, :exists?

      # Return first wrapper object or a collection of first N wrapper
      # objects if the argument is provided.
      # Tries to use cached results of possible. If the amount of
      # cached results is insufficient - performs a new request.
      #
      # @overload first
      #   If nothing is passed - it returns a single object.
      #
      #   @return [Chewy::Type] result document
      #
      # @overload first(limit)
      #   If limit is provided - it returns the limit amount or less
      #   of wrapper objects.
      #
      #   @param limit [Integer] amount of requested results
      #   @return [Array<Chewy::Type>] result document collection
      def first(limit = UNDEFINED)
        request_limit = limit == UNDEFINED ? 1 : limit

        if performed? && (request_limit <= size || size == total)
          limit == UNDEFINED ? wrappers.first : wrappers.first(limit)
        else
          result = except(EXTRA_STORAGES).limit(request_limit).to_a
          limit == UNDEFINED ? result.first : result
        end
      end

      # Finds documents with specified ids for the current request scope.
      #
      # @raise [Chewy::DocumentNotFound] in case of any document is missing
      # @overload find(id)
      #   If single id is passed - it returns a single object.
      #
      #   @param id [Integer, String] id of the desired document
      #   @return [Chewy::Type] result document
      #
      # @overload find(*ids)
      #   If several field are passed - it returns an array of wrappers.
      #   Respect the amount of passed ids and if it is more than the default
      #   batch size - uses scroll API to retrieve everything.
      #
      #   @param ids [Array<Integer, String>] ids of the desired documents
      #   @return [Array<Chewy::Type>] result documents
      def find(*ids)
        return super if block_given?

        ids = ids.flatten(1).map(&:to_s)
        scope = except(EXTRA_STORAGES).filter(ids: {values: ids})

        results = if ids.size > DEFAULT_BATCH_SIZE
          scope.scroll_wrappers
        else
          scope.limit(ids.size)
        end.to_a

        if ids.size != results.size
          missing_ids = ids - results.map(&:id).map(&:to_s)
          raise Chewy::DocumentNotFound, "Could not find documents for ids: #{missing_ids.to_sentence}"
        end
        results.one? ? results.first : results
      end

      # Returns and array of values for specified fields.
      # Uses `source` to restrict the list of returned fields.
      # Fields `_id`, `_type` and `_index` are also supported.
      #
      # @overload pluck(field)
      #   If single field is passed - it returns and array of values.
      #
      #   @param field [String, Symbol] field name
      #   @return [Array<Object>] specified field values
      #
      # @overload pluck(*fields)
      #   If several field are passed - it returns an array of arrays of values.
      #
      #   @param fields [Array<String, Symbol>] field names
      #   @return [Array<Array<Object>>] specified field values
      def pluck(*fields)
        fields = fields.flatten(1).reject(&:blank?).map(&:to_s)

        source_fields = fields - EVERFIELDS
        scope = except(FIELD_STORAGES, EXTRA_STORAGES)
          .source(source_fields.presence || false)

        hits = raw_limit_value ? scope.hits : scope.scroll_hits(batch_size: DEFAULT_PLUCK_BATCH_SIZE)
        hits.map do |hit|
          if fields.one?
            fetch_field(hit, fields.first)
          else
            fields.map do |field|
              fetch_field(hit, field)
            end
          end
        end
      end

      # Deletes all the documents from the specified scope it uses
      # `delete_by_query` API. For ES < 5.0 it uses `delete_by_query`
      # plugin, which requires additional installation effort.
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete-by-query.html
      # @see https://www.elastic.co/guide/en/elasticsearch/plugins/2.0/plugins-delete-by-query.html
      # @note The result hash is different for different API used.
      # @param refresh [true, false] field names
      # @return [Hash] the result of query execution
      def delete_all(refresh: true)
        request_body = only(WHERE_STORAGES).render.merge(refresh: refresh)
        ActiveSupport::Notifications.instrument 'delete_query.chewy',
          request: request_body, indexes: _indexes, types: _types,
          index: _indexes.one? ? _indexes.first : _indexes,
          type: _types.one? ? _types.first : _types do
            if Runtime.version < '5.0'
              delete_by_query_plugin(request_body)
            else
              Chewy.client.delete_by_query(request_body)
            end
          end
      end

    protected

      def initialize_clone(origin)
        @parameters = origin.parameters.clone
        reset
      end

    private

      def compare_internals(other)
        _indexes.sort_by(&:derivable_name) == other._indexes.sort_by(&:derivable_name) &&
          _types.sort_by(&:derivable_name) == other._types.sort_by(&:derivable_name) &&
          parameters == other.parameters
      end

      def modify(name, &block)
        chain { parameters.modify!(name, &block) }
      end

      def chain(&block)
        clone.tap { |r| r.instance_exec(&block) }
      end

      def reset
        @response, @render, @render_base, @type_names, @index_names, @loader = nil
      end

      def perform(additional = {})
        request_body = render.merge(additional)
        ActiveSupport::Notifications.instrument 'search_query.chewy',
          request: request_body, indexes: _indexes, types: _types,
          index: _indexes.one? ? _indexes.first : _indexes,
          type: _types.one? ? _types.first : _types do
          begin
            Chewy.client.search(request_body)
          rescue Elasticsearch::Transport::Transport::Errors::NotFound
            {}
          end
        end
      end

      def raw_limit_value
        parameters[:limit].value
      end

      def raw_offset_value
        parameters[:offset].value
      end

      def index_names
        @index_names ||= _indexes.map(&:index_name).uniq
      end

      def type_names
        @type_names ||= if parameters[:types].value.present?
          _types.map(&:type_name).uniq & parameters[:types].value
        else
          _types.map(&:type_name).uniq
        end
      end

      def render_base
        @render_base ||= {index: index_names, type: type_names, body: {}}
      end

      def delete_by_query_plugin(request)
        path = Elasticsearch::API::Utils.__pathify(
          Elasticsearch::API::Utils.__listify(request[:index]),
          Elasticsearch::API::Utils.__listify(request[:type]),
          '_query'
        )
        Chewy.client.perform_request(Elasticsearch::API::HTTP_DELETE, path, {}, request[:body]).body
      end

      def loader
        @loader ||= Loader.new(indexes: @_indexes, **parameters[:load].value)
      end

      def fetch_field(hit, field)
        if EVERFIELDS.include?(field)
          hit[field]
        else
          hit.fetch('_source', {})[field]
        end
      end

      def performed?
        !@response.nil?
      end

      def collection_paginator
        method(:paginated_collection).to_proc if respond_to?(:paginated_collection, true)
      end
    end
  end
end
