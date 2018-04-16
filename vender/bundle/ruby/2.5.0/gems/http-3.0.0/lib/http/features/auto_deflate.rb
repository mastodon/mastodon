# frozen_string_literal: true

require "zlib"
require "tempfile"

module HTTP
  module Features
    class AutoDeflate < Feature
      attr_reader :method

      def initialize(*)
        super

        @method = @opts.key?(:method) ? @opts[:method].to_s : "gzip"

        raise Error, "Only gzip and deflate methods are supported" unless %w[gzip deflate].include?(@method)
      end

      def deflated_body(body)
        case method
        when "gzip"
          GzippedBody.new(body)
        when "deflate"
          DeflatedBody.new(body)
        else
          raise ArgumentError, "Unsupported deflate method: #{method}"
        end
      end

      class CompressedBody
        def initialize(body)
          @body       = body
          @compressed = nil
        end

        def size
          compress_all! unless @compressed
          @compressed.size
        end

        def each(&block)
          return to_enum __method__ unless block

          if @compressed
            compressed_each(&block)
          else
            compress(&block)
          end

          self
        end

        private

        def compressed_each
          while (data = @compressed.read(Connection::BUFFER_SIZE))
            yield data
          end
        ensure
          @compressed.close!
        end

        def compress_all!
          @compressed = Tempfile.new("http-compressed_body", :binmode => true)
          compress { |data| @compressed.write(data) }
          @compressed.rewind
        end
      end

      class GzippedBody < CompressedBody
        def compress(&block)
          gzip = Zlib::GzipWriter.new(BlockIO.new(block))
          @body.each { |chunk| gzip.write(chunk) }
        ensure
          gzip.finish
        end

        class BlockIO
          def initialize(block)
            @block = block
          end

          def write(data)
            @block.call(data)
          end
        end
      end

      class DeflatedBody < CompressedBody
        def compress
          deflater = Zlib::Deflate.new

          @body.each { |chunk| yield deflater.deflate(chunk) }

          yield deflater.finish
        ensure
          deflater.close
        end
      end
    end
  end
end
