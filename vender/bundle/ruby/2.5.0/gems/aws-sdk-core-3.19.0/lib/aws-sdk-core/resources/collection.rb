module Aws
  module Resources
    class Collection

      extend Aws::Deprecations
      include Enumerable

      # @param [Enumerator<Array>] batches
      # @option options [Integer] :limit
      # @option options [Integer] :size
      # @api private
      def initialize(batches, options = {})
        @batches = batches
        @limit = options[:limit]
        @size = options[:size]
      end

      # @return [Integer,nil]
      #   Returns the size of this collection if known, returns `nil` when
      #   an API call is necessary to enumerate items in this collection.
      def size
        @size
      end
      alias :length :size

      # @deprecated
      # @api private
      def batches
        ::Enumerator.new do |y|
          batch_enum.each do |batch|
            y << self.class.new([batch], size: batch.size)
          end
        end
      end

      # @deprecated
      # @api private
      def [](index)
        if @size
          @batches[0][index]
        else
          raise "unabled to index into a lazy loaded collection"
        end
      end
      deprecated :[]

      # @return [Enumerator<Band>]
      def each(&block)
        enum = ::Enumerator.new do |y|
          batch_enum.each do |batch|
            batch.each do |band|
              y.yield(band)
            end
          end
        end
        enum.each(&block) if block
        enum
      end

      # @param [Integer] count
      # @return [Resource, Collection]
      def first(count = nil)
        if count
          items = limit(count).to_a
          self.class.new([items], size: items.size)
        else
          begin
            each.next
          rescue StopIteration
            nil
          end
        end
      end

      # Returns a new collection that will enumerate a limited number of items.
      #
      #     collection.limit(10).each do |band|
      #       # yields at most 10 times
      #     end
      #
      # @return [Collection]
      # @param [Integer] limit
      def limit(limit)
        Collection.new(@batches, limit: limit)
      end

      private

      def batch_enum
        case @limit
        when 0 then []
        when nil then non_empty_batches
        else limited_batches
        end
      end

      def non_empty_batches
        ::Enumerator.new do |y|
          @batches.each do |batch|
            y.yield(batch) if batch.size > 0
          end
        end
      end

      def limited_batches
        ::Enumerator.new do |y|
          yielded = 0
          @batches.each do |batch|
            batch = batch.take(@limit - yielded)
            if batch.size > 0
              y.yield(batch)
              yielded += batch.size
            end
            break if yielded == @limit
          end
        end
      end

    end
  end
end
