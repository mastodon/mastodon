require 'elasticsearch/dsl'

module Chewy
  module Search
    class Parameters
      # This is a basic storage implementation for `query`, `filter`
      # and `post_filter` storages. It uses `bool` query as a root
      # structure for each of them. The `bool` root is ommited on
      # rendering if there is only a single query in the `must` or
      # `should` array. Besides the standard parameter storage
      # capabilities, it provides specialized methods for the `bool`
      # query component arrays separate update.
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html
      # @see Chewy::Search::Parameters::Query
      # @see Chewy::Search::Parameters::Filter
      # @see Chewy::Search::Parameters::PostFilter
      module QueryStorage
        # Bool storage value object, encapsulates update and query
        # rendering logic.
        #
        # @!attribute must
        #   @return [Array<Hash>, Hash, nil]
        # @!attribute should
        #   @return [Array<Hash>, Hash, nil]
        # @!attribute must_not
        #   @return [[Array<Hash>, Hash, nil]
        # @!attribute minimum_should_match
        #   @return [String, Integer, nil]
        class Bool
          # Acceptable bool query keys
          KEYS = %i[must should must_not minimum_should_match].freeze
          # @!ignorewarning
          attr_reader(*KEYS)

          # @param must [Array<Hash>, Hash, nil]
          # @param should [Array<Hash>, Hash, nil]
          # @param must_not [Array<Hash>, Hash, nil]
          # @param minimum_should_match [String, Integer, nil]
          def initialize(must: [], should: [], must_not: [], minimum_should_match: nil)
            @must = normalize(must)
            @should = normalize(should)
            @must_not = normalize(must_not)
            @minimum_should_match = minimum_should_match
          end

          # Merges 2 values, returns new value object.
          #
          # @param other [Chewy::Search::Parameters::QueryStorage::Bool]
          # @return [Chewy::Search::Parameters::QueryStorage::Bool]
          def update(other)
            self.class.new(
              must: must + other.must,
              should: should + other.should,
              must_not: must_not + other.must_not,
              minimum_should_match: other.minimum_should_match
            )
          end

          # Renders `bool` query.
          #
          # @return [Hash, nil]
          def query
            if must.one? && should.empty? && must_not.empty?
              must.first
            else
              reduced = reduce
              {bool: reduce} if reduced.present?
            end
          end

          # Just a convention.
          #
          # @return [{Symbol => Array<Hash>, String, Integer, nil}]
          def to_h
            {
              must: must,
              should: should,
              must_not: must_not,
              minimum_should_match: minimum_should_match
            }
          end

        private

          def reduce
            value = to_h
              .reject { |_, v| v.blank? }
              .map { |k, v| [k, v.is_a?(Array) && v.one? ? v.first : v] }.to_h
            value.delete(:minimum_should_match) if should.empty?
            value
          end

          def normalize(queries)
            Array.wrap(queries).map do |query|
              if query.is_a?(Proc)
                Elasticsearch::DSL::Search::Query.new(&query).to_hash
              else
                query
              end
            end.reject(&:blank?)
          end
        end

        # Directly modifies `must` array of the root `bool` query.
        # Pushes the passed query to the end of the array.
        #
        # @see Chewy::Search::QueryProxy#must
        # @param other_value [Hash, Array] any acceptable storage value
        # @return [{Symbol => Array<Hash>}]
        def must(other_value)
          update!(must: other_value)
        end

        # Directly modifies `should` array of the root `bool` query.
        # Pushes the passed query to the end of the array.
        #
        # @see Chewy::Search::QueryProxy#should
        # @param other_value [Hash, Array] any acceptable storage value
        # @return [{Symbol => Array<Hash>}]
        def should(other_value)
          update!(should: other_value)
        end

        # Directly modifies `must_not` array of the root `bool` query.
        # Pushes the passed query to the end of the array.
        #
        # @see Chewy::Search::QueryProxy#must_not
        # @param other_value [Hash, Array] any acceptable storage value
        # @return [{Symbol => Array<Hash>}]
        def must_not(other_value)
          update!(must_not: other_value)
        end

        # Unlike {#must} doesn't modify `must` array, but joins 2 queries
        # into a single `must` array of the new root `bool` query.
        # If any of the used queries is a `bool` query from the storage
        # and contains a single query in `must` or `should` array, it will
        # be reduced to this query, so in some cases it will act exactly
        # the same way as {#must}.
        #
        # @see Chewy::Search::QueryProxy#and
        # @param other_value [Hash, Array] any acceptable storage value
        # @return [{Symbol => Array<Hash>}]
        def and(other_value)
          join_into(:must, other_value)
        end

        # Unlike {#should} doesn't modify `should` array, but joins 2 queries
        # into a single `should` array of the new root `bool` query.
        # If any of the used queries is a `bool` query from the storage
        # and contains a single query in `must` or `should` array, it will
        # be reduced to this query, so in some cases it will act exactly
        # the same way as {#should}.
        #
        # @see Chewy::Search::QueryProxy#or
        # @param other_value [Hash, Array] any acceptable storage value
        # @return [{Symbol => Array<Hash>}]
        def or(other_value)
          join_into(:should, other_value)
        end

        # Basically, an alias for {#must_not}.
        #
        # @see #must_not
        # @see Chewy::Search::QueryProxy#not
        # @param other_value [Hash, Array] any acceptable storage value
        # @return [{Symbol => Array<Hash>}]
        def not(other_value)
          update!(must_not: normalize(other_value).query)
        end

        # Replaces `minimum_should_match` bool query value
        #
        # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-minimum-should-match.html
        # @param new_value [String, Integer] minimum_should_match value
        # @return [{Symbol => Array<Hash>}]
        def minimum_should_match(new_value)
          update!(minimum_should_match: new_value)
        end

        # Uses `and` logic to merge storages.
        #
        # @see #and
        # @see Chewy::Search::Parameters::Storage#merge!
        # @param other [Chewy::Search::Parameters::Storage] other storage
        # @return [{Symbol => Array<Hash>}]
        def merge!(other)
          self.and(other.value)
        end

        # Every query value is a hash of arrays and each array is
        # glued with the corresponding array from the provided value.
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [Hash, Array] any acceptable storage value
        # @return [{Symbol => Array<Hash>}]
        def update!(other_value)
          @value = value.update(normalize(other_value))
        end

        # Almost standard rendering logic, some reduction logic is
        # applied to the value additionally.
        #
        # @see Chewy::Search::Parameters::Storage#render
        # @return [{Symbol => Hash}]
        def render
          rendered_bool = value.query
          {self.class.param_name => rendered_bool} if rendered_bool.present?
        end

      private

        def join_into(place, other_value)
          values = [value, normalize(other_value)]
          queries = values.map(&:query)
          if queries.all?
            replace!(place => queries)
          elsif queries.none?
            @value
          else
            replace!(values[queries.index(&:present?)])
          end
        end

        def normalize(value)
          value ||= {}
          if value.is_a?(Hash)
            value = value.symbolize_keys
            value = Bool.new(**value.slice(*Bool::KEYS)) if (value.keys & Bool::KEYS).present?
          end
          value = Bool.new(must: value) unless value.is_a?(Bool)
          value
        end
      end
    end
  end
end
