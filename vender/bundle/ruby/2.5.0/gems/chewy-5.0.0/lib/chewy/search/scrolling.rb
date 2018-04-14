module Chewy
  module Search
    # This module contains batch requests DSL via ES scroll API. All the methods
    # are optimized on memory consumption, they are not caching anythig, so
    # use them when you need to do some single-run stuff on a huge amount of
    # documents. Don't forget to tune the `scroll` parameter for long-lasting
    # actions.
    # All the scroll methods respect the limit value if provided.
    #
    # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
    module Scrolling
      # Iterates through the documents of the scope in batches. Limit if overrided
      # by the `batch_size`. There are 2 possible use-cases: with a block or without.
      #
      # @param batch_size [Integer] batch size obviously, replaces `size` query parameter
      # @param scroll [String] cursor expiration time
      #
      # @overload scroll_batches(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_batches { |batch| batch.each { |hit| p hit['_id'] } }
      #   @yieldparam batch [Array<Hash>] block is executed for each batch of hits
      #
      # @overload scroll_batches(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_batches.flat_map { |batch| batch.map { |hit| hit['_id'] } }
      #   @return [Enumerator] a standard ruby Enumerator
      def scroll_batches(batch_size: Request::DEFAULT_BATCH_SIZE, scroll: Request::DEFAULT_SCROLL)
        return enum_for(:scroll_batches, batch_size: batch_size, scroll: scroll) unless block_given?

        result = perform(size: batch_size, scroll: scroll)
        total = [raw_limit_value, result.fetch('hits', {}).fetch('total', 0)].compact.min
        last_batch_size = total % batch_size
        fetched = 0

        loop do
          hits = result.fetch('hits', {}).fetch('hits', [])
          fetched += hits.size
          hits = hits.first(last_batch_size) if last_batch_size != 0 && fetched >= total
          yield(hits) if hits.present?
          break if fetched >= total
          scroll_id = result['_scroll_id']
          result = perform_scroll(scroll: scroll, scroll_id: scroll_id)
        end
      end

      # @!method scroll_hits(batch_size: 1000, scroll: '1m')
      # Iterates through the documents of the scope in batches. Yields each hit separately.
      #
      # @param batch_size [Integer] batch size obviously, replaces `size` query parameter
      # @param scroll [String] cursor expiration time
      #
      # @overload scroll_hits(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_hits { |hit| p hit['_id'] }
      #   @yieldparam hit [Hash] block is executed for each hit
      #
      # @overload scroll_hits(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_hits.map { |hit| hit['_id'] }
      #   @return [Enumerator] a standard ruby Enumerator
      def scroll_hits(**options)
        return enum_for(:scroll_hits, **options) unless block_given?

        scroll_batches(**options).each do |batch|
          batch.each { |hit| yield hit }
        end
      end

      # @!method scroll_wrappers(batch_size: 1000, scroll: '1m')
      # Iterates through the documents of the scope in batches. Yields
      # each hit wrapped with {Chewy::Type}.
      #
      # @param batch_size [Integer] batch size obviously, replaces `size` query parameter
      # @param scroll [String] cursor expiration time
      #
      # @overload scroll_wrappers(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_wrappers { |object| p object.id }
      #   @yieldparam object [Chewy::Type] block is executed for each hit object
      #
      # @overload scroll_wrappers(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_wrappers.map { |object| object.id }
      #   @return [Enumerator] a standard ruby Enumerator
      def scroll_wrappers(**options)
        return enum_for(:scroll_wrappers, **options) unless block_given?

        scroll_hits(**options).each do |hit|
          yield loader.derive_type(hit['_index'], hit['_type']).build(hit)
        end
      end

      # @!method scroll_objects(batch_size: 1000, scroll: '1m')
      # Iterates through the documents of the scope in batches. Performs load
      # operation for each batch and then yields each loaded ORM/ODM object.
      # Uses {Chewy::Search::Request#load} passed options for loading.
      #
      # @note If the record is not found it yields nil instead.
      # @see Chewy::Search::Request#load
      # @see Chewy::Search::Loader
      # @param batch_size [Integer] batch size obviously, replaces `size` query parameter
      # @param scroll [String] cursor expiration time
      #
      # @overload scroll_objects(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_objects { |record| p record.id }
      #   @yieldparam record [Object] block is executed for each record loaded
      #
      # @overload scroll_objects(batch_size: 1000, scroll: '1m')
      #   @example
      #     PlaceIndex.scroll_objects.map { |record| record.id }
      #   @return [Enumerator] a standard ruby Enumerator
      def scroll_objects(**options)
        return enum_for(:scroll_objects, **options) unless block_given?

        except(:source, :stored_fields, :script_fields, :docvalue_fields)
          .source(false).scroll_batches(**options).each do |batch|
            loader.load(batch).each { |object| yield object }
          end
      end
      alias_method :scroll_records, :scroll_objects
      alias_method :scroll_documents, :scroll_objects

    private

      def perform_scroll(body)
        ActiveSupport::Notifications.instrument 'search_query.chewy',
          request: body, indexes: _indexes, types: _types,
          index: _indexes.one? ? _indexes.first : _indexes,
          type: _types.one? ? _types.first : _types do
          Chewy.client.scroll(body)
        end
      end
    end
  end
end
