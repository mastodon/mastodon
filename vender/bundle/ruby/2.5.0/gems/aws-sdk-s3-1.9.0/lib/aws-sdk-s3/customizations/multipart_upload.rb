module Aws
  module S3
    class MultipartUpload

      alias_method :basic_complete, :complete

      # Completes the upload, requires a list of completed parts. You can
      # provide the list of parts with `:part_number` and `:etag` values.
      #
      #     upload.complete(multipart_upload: { parts: [
      #       { part_number: 1, etag:'etag1' },
      #       { part_number: 2, etag:'etag2' },
      #       ...
      #     ]})
      #
      # Alternatively, you can pass **`compute_parts: true`** and the part
      # list will be computed by calling {Client#list_parts}.
      #
      #     upload.complete(compute_parts: true)
      #
      # @option options [Boolean] :compute_parts (false) When `true`,
      #   the {Client#list_parts} method will be called to determine
      #   the list of required part numbers and their ETags.
      #
      def complete(options = {})
        if options.delete(:compute_parts)
          options[:multipart_upload] = { parts: compute_parts }
        end
        basic_complete(options)
      end

      private

      def compute_parts
        parts.sort_by(&:part_number).each.with_object([]) do |part, part_list|
          part_list << { part_number: part.part_number, etag: part.etag }
        end
      end

    end
  end
end
