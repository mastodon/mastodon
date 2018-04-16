require 'chewy/query/criteria'
require 'chewy/query/filters'
require 'chewy/query/loading'
require 'chewy/query/pagination'

module Chewy
  # Query allows you to create ES search requests with convenient
  # chainable DSL. Queries are lazy evaluated and might be merged.
  # The same DSL is used for whole index or individual types query build.
  #
  # @example
  #   UsersIndex.filter{ age < 42 }.query(text: {name: 'Alex'}).limit(20)
  #   UsersIndex::User.filter{ age < 42 }.query(text: {name: 'Alex'}).limit(20)
  #
  class Query
    include Enumerable
    include Loading
    include Pagination
    include Chewy::Search::Scoping

    DELEGATED_METHODS = %i[
      explain query_mode filter_mode post_filter_mode
      timeout limit offset highlight min_score rescore facets script_score
      boost_factor weight random_score field_value_factor decay aggregations
      suggest none strategy query filter post_filter boost_mode
      score_mode order reorder only types delete_all find total
      total_count total_entries unlimited script_fields track_scores preference
    ].to_set.freeze

    delegate :each, :count, :size, to: :_collection
    alias_method :to_ary, :to_a

    attr_reader :_indexes, :_types, :options, :criteria

    def initialize(*indexes_or_types_and_options)
      @options = indexes_or_types_and_options.extract_options!
      @_types = indexes_or_types_and_options.select { |klass| klass < Chewy::Type }
      @_indexes = indexes_or_types_and_options.select { |klass| klass < Chewy::Index }
      @_indexes |= @_types.map(&:index)
      @criteria = Criteria.new
    end

    # Comparation with other query or collection
    # If other is collection - search request is executed and
    # result is used for comparation
    #
    # @example
    #   UsersIndex.filter(term: {name: 'Johny'}) == UsersIndex.filter(term: {name: 'Johny'}) # => true
    #   UsersIndex.filter(term: {name: 'Johny'}) == UsersIndex.filter(term: {name: 'Johny'}).to_a # => true
    #   UsersIndex.filter(term: {name: 'Johny'}) == UsersIndex.filter(term: {name: 'Winnie'}) # => false
    #
    def ==(other)
      super || other.is_a?(self.class) ? other.criteria == criteria : other == to_a
    end

    # Adds `explain` parameter to search request.
    #
    # @example
    #   UsersIndex.filter(term: {name: 'Johny'}).explain
    #   UsersIndex.filter(term: {name: 'Johny'}).explain(true)
    #   UsersIndex.filter(term: {name: 'Johny'}).explain(false)
    #
    # Calling explain without any arguments sets explanation flag to true.
    # With `explain: true`, every result object has `_explanation`
    # method
    #
    # @example
    #   UsersIndex::User.filter(term: {name: 'Johny'}).explain.first._explanation # => {...}
    #
    def explain(value = nil)
      chain { criteria.update_request_options explain: (value.nil? ? true : value) }
    end

    # Adds `script_fields` parameter to search request.
    #
    # @example
    #  UsersIndex.script_fields(
    #    distance: {
    #      params: {
    #        lat: 37.569976,
    #        lon: -122.351591
    #      },
    #      script: "doc['coordinates'].distanceInMiles(lat, lon)"
    #    }
    #  )
    def script_fields(value)
      chain { criteria.update_script_fields(value) }
    end

    # Sets query compilation mode for search request.
    # Not used if only one filter for search is specified.
    # Possible values:
    #
    # * `:must`
    #   Default value. Query compiles into a bool `must` query.
    #
    # @example
    #     UsersIndex.query(text: {name: 'Johny'}).query(range: {age: {lte: 42}})
    #       # => {body: {
    #              query: {bool: {must: [{text: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}}
    #            }}
    #
    # * `:should`
    #   Query compiles into a bool `should` query.
    #
    # @example
    #     UsersIndex.query(text: {name: 'Johny'}).query(range: {age: {lte: 42}}).query_mode(:should)
    #       # => {body: {
    #              query: {bool: {should: [{text: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}}
    #            }}
    #
    # * Any acceptable `minimum_should_match` value (1, '2', '75%')
    #   Query compiles into a bool `should` query with `minimum_should_match` set.
    #
    # @example
    #     UsersIndex.query(text: {name: 'Johny'}).query(range: {age: {lte: 42}}).query_mode('50%')
    #       # => {body: {
    #              query: {bool: {
    #                should: [{text: {name: 'Johny'}}, {range: {age: {lte: 42}}}],
    #                minimum_should_match: '50%'
    #              }}
    #            }}
    #
    # * `:dis_max`
    #   Query compiles into a `dis_max` query.
    #
    # @example
    #     UsersIndex.query(text: {name: 'Johny'}).query(range: {age: {lte: 42}}).query_mode(:dis_max)
    #       # => {body: {
    #              query: {dis_max: {queries: [{text: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}}
    #            }}
    #
    # * Any Float value (0.0, 0.7, 1.0)
    #   Query compiles into a `dis_max` query with `tie_breaker` option set.
    #
    # @example
    #     UsersIndex.query(text: {name: 'Johny'}).query(range: {age: {lte: 42}}).query_mode(0.7)
    #       # => {body: {
    #              query: {dis_max: {
    #                queries: [{text: {name: 'Johny'}}, {range: {age: {lte: 42}}}],
    #                tie_breaker: 0.7
    #              }}
    #            }}
    #
    # Default value for `:query_mode` might be changed
    # with `Chewy.query_mode` config option.
    #
    # @example
    #   Chewy.query_mode = :dis_max
    #   Chewy.query_mode = '50%'
    #
    def query_mode(value)
      chain { criteria.update_options query_mode: value }
    end

    # Sets query compilation mode for search request.
    # Not used if only one filter for search is specified.
    # Possible values:
    #
    # * `:and`
    #   Default value. Filter compiles into an `and` filter.
    #
    # @example
    #     UsersIndex.filter{ name == 'Johny' }.filter{ age <= 42 }
    #       # => {body: {query: {filtered: {
    #              query: {...},
    #              filter: {and: [{term: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}
    #            }}}}
    #
    # * `:or`
    #   Filter compiles into an `or` filter.
    #
    # @example
    #     UsersIndex.filter{ name == 'Johny' }.filter{ age <= 42 }.filter_mode(:or)
    #       # => {body: {query: {filtered: {
    #              query: {...},
    #              filter: {or: [{term: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}
    #            }}}}
    #
    # * `:must`
    #   Filter compiles into a bool `must` filter.
    #
    # @example
    #     UsersIndex.filter{ name == 'Johny' }.filter{ age <= 42 }.filter_mode(:must)
    #       # => {body: {query: {filtered: {
    #              query: {...},
    #              filter: {bool: {must: [{term: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}}
    #            }}}}
    #
    # * `:should`
    #   Filter compiles into a bool `should` filter.
    #
    # @example
    #     UsersIndex.filter{ name == 'Johny' }.filter{ age <= 42 }.filter_mode(:should)
    #       # => {body: {query: {filtered: {
    #              query: {...},
    #              filter: {bool: {should: [{term: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}}
    #            }}}}
    #
    # * Any acceptable `minimum_should_match` value (1, '2', '75%')
    #   Filter compiles into bool `should` filter with `minimum_should_match` set.
    #
    # @example
    #     UsersIndex.filter{ name == 'Johny' }.filter{ age <= 42 }.filter_mode('50%')
    #       # => {body: {query: {filtered: {
    #              query: {...},
    #              filter: {bool: {
    #                should: [{term: {name: 'Johny'}}, {range: {age: {lte: 42}}}],
    #                minimum_should_match: '50%'
    #              }}
    #            }}}}
    #
    # Default value for `:filter_mode` might be changed
    # with `Chewy.filter_mode` config option.
    #
    # @example
    #   Chewy.filter_mode = :should
    #   Chewy.filter_mode = '50%'
    #
    def filter_mode(value)
      chain { criteria.update_options filter_mode: value }
    end

    # Acts the same way as `filter_mode`, but used for `post_filter`.
    # Note that it fallbacks by default to `Chewy.filter_mode` if
    # `Chewy.post_filter_mode` is nil.
    #
    # @example
    #   UsersIndex.post_filter{ name == 'Johny' }.post_filter{ age <= 42 }.post_filter_mode(:and)
    #   UsersIndex.post_filter{ name == 'Johny' }.post_filter{ age <= 42 }.post_filter_mode(:should)
    #   UsersIndex.post_filter{ name == 'Johny' }.post_filter{ age <= 42 }.post_filter_mode('50%')
    #
    def post_filter_mode(value)
      chain { criteria.update_options post_filter_mode: value }
    end

    # A search timeout, bounding the search request to be executed within the
    # specified time value and bail with the hits accumulated up to that point
    # when expired. Defaults to no timeout.
    #
    # By default, the coordinating node waits to receive a response from all
    # shards. If one node is having trouble, it could slow down the response to
    # all search requests.
    #
    # The timeout parameter tells the coordinating node how long it should wait
    # before giving up and just returning the results that it already has. It
    # can be better to return some results than none at all.
    #
    # The response to a search request will indicate whether the search timed
    # out and how many shards responded successfully:
    #
    # @example
    #   ...
    #   "timed_out":     true,
    #   "_shards": {
    #       "total":      5,
    #       "successful": 4,
    #       "failed":     1
    #   },
    #   ...
    #
    # The primary shard assigned to perform the index operation might not be
    # available when the index operation is executed. Some reasons for this
    # might be that the primary shard is currently recovering from a gateway or
    # undergoing relocation. By default, the index operation will wait on the
    # primary shard to become available for up to 1 minute before failing and
    # responding with an error. The timeout parameter can be used to explicitly
    # specify how long it waits.
    #
    # @example
    #   UsersIndex.timeout("5000ms")
    #
    # Timeout is not a circuit breaker.
    #
    # It should be noted that this timeout does not halt the execution of the
    # query, it merely tells the coordinating node to return the results
    # collected so far and to close the connection. In the background, other
    # shards may still be processing the query even though results have been
    # sent.
    #
    # Use the timeout because it is important to your SLA, not because you want
    # to abort the execution of long running queries.
    #
    def timeout(value)
      chain { criteria.update_request_options timeout: value }
    end

    # Sets elasticsearch `size` search request param
    # Default value is set in the elasticsearch and is 10.
    #
    # @example
    #  UsersIndex.filter{ name == 'Johny' }.limit(100)
    #     # => {body: {
    #            query: {...},
    #            size: 100
    #          }}
    #
    def limit(value = nil, &block)
      chain { criteria.update_request_options size: block || Integer(value) }
    end

    # Sets elasticsearch `from` search request param
    #
    # @example
    #  UsersIndex.filter{ name == 'Johny' }.offset(300)
    #     # => {body: {
    #            query: {...},
    #            from: 300
    #          }}
    #
    def offset(value = nil, &block)
      chain { criteria.update_request_options from: block || Integer(value) }
    end

    # Elasticsearch highlight query option support
    #
    # @example
    #   UsersIndex.query(...).highlight(fields: { ... })
    #
    def highlight(value)
      chain { criteria.update_request_options highlight: value }
    end

    # Elasticsearch rescore query option support
    #
    # @example
    #   UsersIndex.query(...).rescore(query: { ... })
    #
    def rescore(value)
      chain { criteria.update_request_options rescore: value }
    end

    # Elasticsearch minscore option support
    #
    # @example
    #   UsersIndex.query(...).min_score(0.5)
    #
    def min_score(value)
      chain { criteria.update_request_options min_score: value }
    end

    # Elasticsearch track_scores option support
    #
    # @example
    #   UsersIndex.query(...).track_scores(true)
    #
    def track_scores(value)
      chain { criteria.update_request_options track_scores: value }
    end

    # Adds facets section to the search request.
    # All the chained facets a merged and added to the
    # search request
    #
    # @example
    #   UsersIndex.facets(tags: {terms: {field: 'tags'}}).facets(ages: {terms: {field: 'age'}})
    #     # => {body: {
    #            query: {...},
    #            facets: {tags: {terms: {field: 'tags'}}, ages: {terms: {field: 'age'}}}
    #          }}
    #
    # If called parameterless - returns result facets from ES performing request.
    # Returns empty hash if no facets was requested or resulted.
    #
    def facets(params = nil)
      raise RemovedFeature, 'removed in elasticsearch 2.0' if Runtime.version >= '2.0'
      if params
        chain { criteria.update_facets params }
      else
        _response['facets'] || {}
      end
    end

    # Adds a script function to score the search request. All scores are
    # added to the search request and combinded according to
    # `boost_mode` and `score_mode`
    #
    # @example
    #   UsersIndex.script_score("doc['boost'].value", params: { modifier: 2 })
    #       # => {body:
    #              query: {
    #                function_score: {
    #                  query: { ...},
    #                  functions: [{
    #                    script_score: {
    #                       script: "doc['boost'].value * modifier",
    #                       params: { modifier: 2 }
    #                     }
    #                    }
    #                  }]
    #                } } }
    def script_score(script, options = {})
      scoring = {script_score: {script: script}.merge(options)}
      chain { criteria.update_scores scoring }
    end

    # Adds a boost factor to the search request. All scores are
    # added to the search request and combinded according to
    # `boost_mode` and `score_mode`
    #
    # This probably only makes sense if you specify a filter
    # for the boost factor as well
    #
    # @example
    #   UsersIndex.boost_factor(23, filter: { term: { foo: :bar} })
    #       # => {body:
    #              query: {
    #                function_score: {
    #                  query: { ...},
    #                  functions: [{
    #                    boost_factor: 23,
    #                    filter: { term: { foo: :bar } }
    #                  }]
    #                } } }
    def boost_factor(factor, options = {})
      scoring = options.merge(boost_factor: factor.to_i)
      chain { criteria.update_scores scoring }
    end

    # Add a weight scoring function to the search. All scores are
    # added to the search request and combinded according to
    # `boost_mode` and `score_mode`
    #
    # This probably only makes sense if you specify a filter
    # for the weight as well.
    #
    # @example
    #   UsersIndex.weight(23, filter: { term: { foo: :bar} })
    #       # => {body:
    #              query: {
    #                function_score: {
    #                  query: { ...},
    #                  functions: [{
    #                    weight: 23,
    #                    filter: { term: { foo: :bar } }
    #                  }]
    #                } } }
    def weight(factor, options = {})
      scoring = options.merge(weight: factor.to_i)
      chain { criteria.update_scores scoring }
    end

    # Adds a random score to the search request. All scores are
    # added to the search request and combinded according to
    # `boost_mode` and `score_mode`
    #
    # This probably only makes sense if you specify a filter
    # for the random score as well.
    #
    # If you do not pass in a seed value, Time.now will be used
    #
    # @example
    #   UsersIndex.random_score(23, filter: { foo: :bar})
    #       # => {body:
    #              query: {
    #                function_score: {
    #                  query: { ...},
    #                  functions: [{
    #                    random_score: { seed: 23 },
    #                    filter: { foo: :bar }
    #                  }]
    #                } } }
    def random_score(seed = Time.now, options = {})
      scoring = options.merge(random_score: {seed: seed.to_i})
      chain { criteria.update_scores scoring }
    end

    # Add a field value scoring to the search. All scores are
    # added to the search request and combinded according to
    # `boost_mode` and `score_mode`
    #
    # This function is only available in Elasticsearch 1.2 and
    # greater
    #
    # @example
    #   UsersIndex.field_value_factor(
    #                {
    #                  field: :boost,
    #                  factor: 1.2,
    #                  modifier: :sqrt
    #                }, filter: { foo: :bar})
    #       # => {body:
    #              query: {
    #                function_score: {
    #                  query: { ...},
    #                  functions: [{
    #                    field_value_factor: {
    #                      field: :boost,
    #                      factor: 1.2,
    #                      modifier: :sqrt
    #                    },
    #                    filter: { foo: :bar }
    #                  }]
    #                } } }
    def field_value_factor(settings, options = {})
      scoring = options.merge(field_value_factor: settings)
      chain { criteria.update_scores scoring }
    end

    # Add a decay scoring to the search. All scores are
    # added to the search request and combinded according to
    # `boost_mode` and `score_mode`
    #
    # The parameters have default values, but those may not
    # be very useful for most applications.
    #
    # @example
    #   UsersIndex.decay(
    #                :gauss,
    #                :field,
    #                origin: '11, 12',
    #                scale: '2km',
    #                offset: '5km',
    #                decay: 0.4,
    #                filter: { foo: :bar})
    #       # => {body:
    #              query: {
    #                gauss: {
    #                  query: { ...},
    #                  functions: [{
    #                    gauss: {
    #                      field: {
    #                        origin: '11, 12',
    #                        scale: '2km',
    #                        offset: '5km',
    #                        decay: 0.4
    #                      }
    #                    },
    #                    filter: { foo: :bar }
    #                  }]
    #                } } }
    def decay(function, field, options = {})
      field_options = options.extract!(:origin, :scale, :offset, :decay).delete_if { |_, v| v.nil? }
      scoring = options.merge(function => {
        field => field_options
      })
      chain { criteria.update_scores scoring }
    end

    # Sets `preference` for request.
    # For instance, one can use `preference=_primary` to execute only on the primary shards.
    #
    # @example
    #   scope = UsersIndex.preference(:_primary)
    #
    def preference(value)
      chain { criteria.update_search_options preference: value }
    end

    # Sets elasticsearch `aggregations` search request param
    #
    # @example
    #  UsersIndex.filter{ name == 'Johny' }.aggregations(category_id: {terms: {field: 'category_ids'}})
    #     # => {body: {
    #            query: {...},
    #            aggregations: {
    #              terms: {
    #                field: 'category_ids'
    #              }
    #            }
    #          }}
    #
    def aggregations(params = nil)
      @_named_aggs ||= _build_named_aggs
      @_fully_qualified_named_aggs ||= _build_fqn_aggs
      if params
        params = {params => @_named_aggs[params]} if params.is_a?(Symbol)
        params = {params => _get_fully_qualified_named_agg(params)} if params.is_a?(String) && params =~ /\A\S+#\S+\.\S+\z/
        chain { criteria.update_aggregations params }
      else
        _response['aggregations'] || {}
      end
    end
    alias_method :aggs, :aggregations

    # In this simplest of implementations each named aggregation must be uniquely named
    def _build_named_aggs
      named_aggs = {}
      @_indexes.each do |index|
        index.types.each do |type|
          type._agg_defs.each do |agg_name, prc|
            named_aggs[agg_name] = prc.call
          end
        end
      end
      named_aggs
    end

    def _build_fqn_aggs
      named_aggs = {}
      @_indexes.each do |index|
        named_aggs[index.to_s.downcase] ||= {}
        index.types.each do |type|
          named_aggs[index.to_s.downcase][type.to_s.downcase] ||= {}
          type._agg_defs.each do |agg_name, prc|
            named_aggs[index.to_s.downcase][type.to_s.downcase][agg_name.to_s.downcase] = prc.call
          end
        end
      end
      named_aggs
    end

    def _get_fully_qualified_named_agg(str)
      parts = str.scan(/\A(\S+)#(\S+)\.(\S+)\z/).first
      idx = "#{parts[0]}index"
      type = "#{idx}::#{parts[1]}"
      agg_name = parts[2]
      @_fully_qualified_named_aggs[idx][type][agg_name]
    end

    # Sets elasticsearch `suggest` search request param
    #
    # @example
    #  UsersIndex.suggest(name: {text: 'Joh', term: {field: 'name'}})
    #     # => {body: {
    #            query: {...},
    #            suggest: {
    #              text: 'Joh',
    #              term: {
    #                field: 'name'
    #              }
    #            }
    #          }}
    #
    def suggest(params = nil)
      if params
        chain { criteria.update_suggest params }
      else
        _response['suggest'] || {}
      end
    end

    # Marks the criteria as having zero documents. This scope  always returns empty array
    # without touching the elasticsearch server.
    # All the chained calls of methods don't affect the result
    #
    # @example
    #   UsersIndex.none.to_a
    #     # => []
    #   UsersIndex.query(text: {name: 'Johny'}).none.to_a
    #     # => []
    #   UsersIndex.none.query(text: {name: 'Johny'}).to_a
    #     # => []
    #
    def none
      chain { criteria.update_options none: true }
    end

    # Setups strategy for top-level filtered query
    #
    # @example
    #    UsersIndex.filter { name == 'Johny'}.strategy(:leap_frog)
    #     # => {body: {
    #            query: { filtered: {
    #              filter: { term: { name: 'Johny' } },
    #              strategy: 'leap_frog'
    #            } }
    #          }}
    #
    def strategy(value = nil)
      chain { criteria.update_options strategy: value }
    end

    # Adds one or more query to the search request
    # Internally queries are stored as an array
    # While the full query compilation this array compiles
    # according to `:query_mode` option value
    #
    # By default it joines inside `must` query
    # See `#query_mode` chainable method for more info.
    #
    # @example
    #   UsersIndex.query(text: {name: 'Johny'}).query(range: {age: {lte: 42}})
    #   UsersIndex::User.query(text: {name: 'Johny'}).query(range: {age: {lte: 42}})
    #     # => {body: {
    #            query: {bool: {must: [{text: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}}
    #          }}
    #
    # If only one query was specified, it will become a result
    # query as is, without joining.
    #
    # @example
    #   UsersIndex.query(text: {name: 'Johny'})
    #     # => {body: {
    #            query: {text: {name: 'Johny'}}
    #          }}
    #
    def query(params)
      chain { criteria.update_queries params }
    end

    # Adds one or more filter to the search request
    # Internally filters are stored as an array
    # While the full query compilation this array compiles
    # according to `:filter_mode` option value
    #
    # By default it joins inside `and` filter
    # See `#filter_mode` chainable method for more info.
    #
    # Also this method supports block DSL.
    # See `Chewy::Query::Filters` for more info.
    #
    # @example
    #   UsersIndex.filter(term: {name: 'Johny'}).filter(range: {age: {lte: 42}})
    #   UsersIndex::User.filter(term: {name: 'Johny'}).filter(range: {age: {lte: 42}})
    #   UsersIndex.filter{ name == 'Johny' }.filter{ age <= 42 }
    #     # => {body: {query: {filtered: {
    #            query: {...},
    #            filter: {and: [{term: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}
    #          }}}}
    #
    # If only one filter was specified, it will become a result
    # filter as is, without joining.
    #
    # @example
    #   UsersIndex.filter(term: {name: 'Johny'})
    #     # => {body: {query: {filtered: {
    #            query: {...},
    #            filter: {term: {name: 'Johny'}}
    #          }}}}
    #
    def filter(params = nil, &block)
      params = Filters.new(&block).__render__ if block
      chain { criteria.update_filters params }
    end

    # Adds one or more post_filter to the search request
    # Internally post_filters are stored as an array
    # While the full query compilation this array compiles
    # according to `:post_filter_mode` option value
    #
    # By default it joins inside `and` filter
    # See `#post_filter_mode` chainable method for more info.
    #
    # Also this method supports block DSL.
    # See `Chewy::Query::Filters` for more info.
    #
    # @example
    #   UsersIndex.post_filter(term: {name: 'Johny'}).post_filter(range: {age: {lte: 42}})
    #   UsersIndex::User.post_filter(term: {name: 'Johny'}).post_filter(range: {age: {lte: 42}})
    #   UsersIndex.post_filter{ name == 'Johny' }.post_filter{ age <= 42 }
    #     # => {body: {
    #            post_filter: {and: [{term: {name: 'Johny'}}, {range: {age: {lte: 42}}}]}
    #          }}
    #
    # If only one post_filter was specified, it will become a result
    # post_filter as is, without joining.
    #
    # @example
    #   UsersIndex.post_filter(term: {name: 'Johny'})
    #     # => {body: {
    #            post_filter: {term: {name: 'Johny'}}
    #          }}
    #
    def post_filter(params = nil, &block)
      params = Filters.new(&block).__render__ if block
      chain { criteria.update_post_filters params }
    end

    # Sets the boost mode for custom scoring/boosting.
    # Not used if no score functions are specified
    # Possible values:
    #
    # * `:multiply`
    #   Default value. Query score and function result are multiplied.
    #
    # @example
    #     UsersIndex.boost_mode('multiply').script_score('doc['boost'].value')
    #       # => {body: {query: function_score: {
    #         query: {...},
    #         boost_mode: 'multiply',
    #         functions: [ ... ]
    #       }}}
    #
    # * `:replace`
    #   Only function result is used, query score is ignored.
    #
    # * `:sum`
    #   Query score and function score are added.
    #
    # * `:avg`
    #   Average of query and function score.
    #
    # * `:max`
    #   Max of query and function score.
    #
    # * `:min`
    #   Min of query and function score.
    #
    # Default value for `:boost_mode` might be changed
    # with `Chewy.score_mode` config option.
    def boost_mode(value)
      chain { criteria.update_options boost_mode: value }
    end

    # Sets the scoring mode for combining function scores/boosts
    # Not used if no score functions are specified.
    # Possible values:
    #
    # * `:multiply`
    #   Default value. Scores are multiplied.
    #
    # @example
    #     UsersIndex.score_mode('multiply').script_score('doc['boost'].value')
    #       # => {body: {query: function_score: {
    #         query: {...},
    #         score_mode: 'multiply',
    #         functions: [ ... ]
    #       }}}
    #
    # * `:sum`
    #   Scores are summed.
    #
    # * `:avg`
    #   Scores are averaged.
    #
    # * `:first`
    #   The first function that has a matching filter is applied.
    #
    # * `:max`
    #   Maximum score is used.
    #
    # * `:min`
    #   Minimum score is used
    #
    # Default value for `:score_mode` might be changed
    # with `Chewy.score_mode` config option.
    #
    # @example
    #   Chewy.score_mode = :first
    #
    def score_mode(value)
      chain { criteria.update_options score_mode: value }
    end

    # Sets search request sorting
    #
    # @example
    #   UsersIndex.order(:first_name, :last_name).order(age: :desc).order(price: {order: :asc, mode: :avg})
    #     # => {body: {
    #            query: {...},
    #            sort: ['first_name', 'last_name', {age: 'desc'}, {price: {order: 'asc', mode: 'avg'}}]
    #          }}
    #
    def order(*params)
      chain { criteria.update_sort params }
    end

    # Cleans up previous search sorting and sets the new one
    #
    # @example
    #   UsersIndex.order(:first_name, :last_name).order(age: :desc).reorder(price: {order: :asc, mode: :avg})
    #     # => {body: {
    #            query: {...},
    #            sort: [{price: {order: 'asc', mode: 'avg'}}]
    #          }}
    #
    def reorder(*params)
      chain { criteria.update_sort params, purge: true }
    end

    # Sets search request field list
    #
    # @example
    #   UsersIndex.only(:first_name, :last_name).only(:age)
    #     # => {body: {
    #            query: {...},
    #            fields: ['first_name', 'last_name', 'age']
    #          }}
    #
    def only(*params)
      chain { criteria.update_fields params }
    end

    # Cleans up previous search field list and sets the new one
    #
    # @example
    #   UsersIndex.only(:first_name, :last_name).only!(:age)
    #     # => {body: {
    #            query: {...},
    #            fields: ['age']
    #          }}
    #
    def only!(*params)
      chain { criteria.update_fields params, purge: true }
    end

    # Specify types participating in the search result
    # Works via `types` filter. Always merged with another filters
    # with the `and` filter.
    #
    # @example
    #   UsersIndex.types(:admin, :manager).filters{ name == 'Johny' }.filters{ age <= 42 }
    #     # => {body: {query: {filtered: {
    #            query: {...},
    #            filter: {and: [
    #              {or: [
    #                {type: {value: 'admin'}},
    #                {type: {value: 'manager'}}
    #              ]},
    #              {term: {name: 'Johny'}},
    #              {range: {age: {lte: 42}}}
    #            ]}
    #          }}}}
    #
    #   UsersIndex.types(:admin, :manager).filters{ name == 'Johny' }.filters{ age <= 42 }.filter_mode(:or)
    #     # => {body: {query: {filtered: {
    #            query: {...},
    #            filter: {and: [
    #              {or: [
    #                {type: {value: 'admin'}},
    #                {type: {value: 'manager'}}
    #              ]},
    #              {or: [
    #                {term: {name: 'Johny'}},
    #                {range: {age: {lte: 42}}}
    #              ]}
    #            ]}
    #          }}}}
    #
    def types(*params)
      chain { criteria.update_types params }
    end

    # Acts the same way as `types`, but cleans up previously set types
    #
    # @example
    #   UsersIndex.types(:admin).types!(:manager)
    #     # => {body: {query: {filtered: {
    #            query: {...},
    #            filter: {type: {value: 'manager'}}
    #          }}}}
    #
    def types!(*params)
      chain { criteria.update_types params, purge: true }
    end

    # Sets `search_type` for request.
    # For instance, one can use `search_type=count` to fetch only total count of documents or to fetch only aggregations without fetching documents.
    #
    # @example
    #   scope = UsersIndex.search_type(:count)
    #   scope.count == 0  # no documents actually fetched
    #   scope.total == 10 # but we know a total count of them
    #
    #   scope = UsersIndex.aggs(max_age: { max: { field: 'age' } }).search_type(:count)
    #   max_age = scope.aggs['max_age']['value']
    #
    def search_type(value)
      chain { criteria.update_search_options search_type: value }
    end

    # Merges two queries.
    # Merges all the values in criteria with the same rules as values added manually.
    #
    # @example
    #   scope1 = UsersIndex.filter{ name == 'Johny' }
    #   scope2 = UsersIndex.filter{ age <= 42 }
    #   scope3 = UsersIndex.filter{ name == 'Johny' }.filter{ age <= 42 }
    #
    #   scope1.merge(scope2) == scope3 # => true
    #
    def merge(other)
      chain { criteria.merge!(other.criteria) }
    end

    # Deletes all documents matching a query.
    #
    # @example
    #   UsersIndex.delete_all
    #   UsersIndex.filter{ age <= 42 }.delete_all
    #   UsersIndex::User.delete_all
    #   UsersIndex::User.filter{ age <= 42 }.delete_all
    #
    def delete_all
      if Runtime.version >= '2.0'
        plugins = Chewy.client.nodes.info(plugins: true)['nodes'].values.map { |item| item['plugins'] }.flatten
        raise PluginMissing, 'install delete-by-query plugin' unless plugins.find { |item| item['name'] == 'delete-by-query' }
      end

      request = chain { criteria.update_options simple: true }.send(:_request)

      ActiveSupport::Notifications.instrument 'delete_query.chewy',
        request: request, indexes: _indexes, types: _types,
        index: _indexes.one? ? _indexes.first : _indexes,
        type: _types.one? ? _types.first : _types do
          if Runtime.version >= '2.0'
            path = Elasticsearch::API::Utils.__pathify(
              Elasticsearch::API::Utils.__listify(request[:index]),
              Elasticsearch::API::Utils.__listify(request[:type]),
              '/_query'
            )
            Chewy.client.perform_request(Elasticsearch::API::HTTP_DELETE, path, {}, request[:body]).body
          else
            Chewy.client.delete_by_query(request)
          end
        end
    end

    # Find all documents matching a query.
    #
    # @example
    #   UsersIndex.find(42)
    #   UsersIndex.filter{ age <= 42 }.find(42)
    #   UsersIndex::User.find(42)
    #   UsersIndex::User.filter{ age <= 42 }.find(42)
    #
    # In all the previous examples find will return a single object.
    # To get a collection - pass an array of ids.
    #
    # @example
    #    UsersIndex::User.find(42, 7, 3) # array of objects with ids in [42, 7, 3]
    #    UsersIndex::User.find([8, 13])  # array of objects with ids in [8, 13]
    #    UsersIndex::User.find([42])     # array of the object with id == 42
    #
    def find(*ids)
      results = chain { criteria.update_options simple: true }.filter { _id == ids.flatten }.to_a

      raise Chewy::DocumentNotFound, "Could not find documents for ids #{ids.flatten}" if results.empty?
      ids.one? && !ids.first.is_a?(Array) ? results.first : results
    end

    # Returns true if there are at least one document that matches the query
    #
    # @example
    #   PlacesIndex.query(...).filter(...).exists?
    #
    def exists?
      search_type(:count).total > 0
    end

    # Sets limit to be equal to total documents count
    #
    # @example
    #  PlacesIndex.query(...).filter(...).unlimited
    #

    def unlimited
      count_query = search_type(:count)
      offset(0).limit { count_query.total }
    end

    # Returns request total time elapsed as reported by elasticsearch
    #
    # @example
    #   UsersIndex.query(...).filter(...).took
    #
    def took
      _response['took']
    end

    # Returns request timed_out as reported by elasticsearch
    #
    # The timed_out value tells us whether the query timed out or not.
    #
    # By default, search requests do not timeout. If low response times are more
    # important to you than complete results, you can specify a timeout as 10 or
    # "10ms" (10 milliseconds), or "1s" (1 second). See #timeout method.
    #
    # @example
    #   UsersIndex.query(...).filter(...).timed_out
    #
    def timed_out
      _response['timed_out']
    end

  protected

    def initialize_clone(origin)
      @criteria = origin.criteria.clone
      reset
    end

  private

    def chain(&block)
      clone.tap { |q| q.instance_exec(&block) }
    end

    def reset
      @_request, @_response, @_results, @_collection = nil
    end

    def _request
      @_request ||= begin
        request = criteria.request_body
        request[:index] = _indexes_hash.keys
        request[:type] = _types.map(&:type_name)
        request
      end
    end

    def _response
      @_response ||= ActiveSupport::Notifications.instrument 'search_query.chewy',
        request: _request, indexes: _indexes, types: _types,
        index: _indexes.one? ? _indexes.first : _indexes,
        type: _types.one? ? _types.first : _types do
        begin
          Chewy.client.search(_request)
        rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
          raise e if e.message !~ /IndexMissingException/ && e.message !~ /index_not_found_exception/
          {}
        end
      end
    end

    def _results
      @_results ||= (criteria.none? || _response == {} ? [] : _response['hits']['hits']).map do |hit|
        _derive_type(hit['_index'], hit['_type']).build(hit)
      end
    end

    def _collection
      @_collection ||= begin
        _load_objects! if criteria.options[:preload]
        if criteria.options[:preload] && criteria.options[:loaded_objects]
          _results.map(&:_object)
        else
          _results
        end
      end
    end

    def _derive_type(index, type)
      (@types_cache ||= {})[[index, type]] ||= _derive_index(index).type(type)
    end

    def _derive_index(index_name)
      (@derive_index ||= {})[index_name] ||= _indexes_hash[index_name] ||
        _indexes_hash[_indexes_hash.keys.sort_by(&:length).reverse.detect { |name| index_name.start_with?(name) }]
    end

    def _indexes_hash
      @_indexes_hash ||= _indexes.index_by(&:index_name)
    end
  end
end
