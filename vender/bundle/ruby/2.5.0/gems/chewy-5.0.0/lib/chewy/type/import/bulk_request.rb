module Chewy
  class Type
    module Import
      # Adds additional features to elasticsearch-api bulk method:
      # * supports Chewy index suffix if necessary;
      # * supports bulk_size, devides the passed body in chunks
      #   and peforms a separate request for each chunk;
      # * returns only errored document entries from the response
      #   if any present.
      #
      # @see https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-api/lib/elasticsearch/api/actions/bulk.rb
      class BulkRequest
        # @param type [Chewy::Type] a type for the request
        # @param suffix [String] an index name optional suffix
        # @param bulk_size [Integer] bulk size in bytes
        # @param bulk_options [Hash] options passed to the elasticsearch-api bulk method
        def initialize(type, suffix: nil, bulk_size: nil, **bulk_options)
          @type = type
          @suffix = suffix
          @bulk_size = bulk_size - 1.kilobyte if bulk_size # 1 kilobyte for request header and newlines
          @bulk_options = bulk_options

          raise ArgumentError, '`bulk_size` can\'t be less than 1 kilobyte' if @bulk_size && @bulk_size <= 0
        end

        # Performs a bulk request with the passed body, returns empty
        # array if everything is fine and array filled with errored
        # document entries if something went wrong.
        #
        # @param body [Array<Hash>] a standard bulk request body
        # @return [Array<Hash>] an array of bulk errors
        def perform(body)
          return [] if body.blank?

          request_bodies(body).each_with_object([]) do |request_body, results|
            response = @type.client.bulk request_base.merge(body: request_body) if request_body.present?

            next unless response.try(:[], 'errors')

            response_items = (response.try(:[], 'items') || [])
              .select { |item| item.values.first['error'] }
            results.concat(response_items)
          end
        end

      private

        def request_base
          @request_base ||= {
            index: @type.index_name(suffix: @suffix),
            type: @type.type_name
          }.merge!(@bulk_options)
        end

        def request_bodies(body)
          if @bulk_size
            pieces = body.each_with_object(['']) do |piece, result|
              operation, meta = piece.to_a.first
              data = meta.delete(:data)
              piece = [{operation => meta}, data].compact.map(&:to_json).join("\n")

              if result.last.bytesize + piece.bytesize > @bulk_size
                result.push(piece)
              else
                result[-1] = [result[-1], piece].reject(&:blank?).join("\n")
              end
            end
            pieces.each { |piece| piece << "\n" }
          else
            [body]
          end
        end
      end
    end
  end
end
