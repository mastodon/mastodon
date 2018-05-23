module Sprockets
  module Utils
    class Gzip
      # Private: Generates a gzipped file based off of reference file.
      def initialize(asset)
        @content_type  = asset.content_type
        @source        = asset.source
        @charset       = asset.charset
      end

      # What non-text mime types should we compress? This list comes from:
      # https://www.fastly.com/blog/new-gzip-settings-and-deciding-what-compress
      COMPRESSABLE_MIME_TYPES = {
        "application/vnd.ms-fontobject" => true,
        "application/x-font-opentype" => true,
        "application/x-font-ttf" => true,
        "image/x-icon" => true,
        "image/svg+xml" => true
      }

      # Private: Returns whether or not an asset can be compressed.
      #
      # We want to compress any file that is text based.
      # You do not want to compress binary
      # files as they may already be compressed and running them
      # through a compression algorithm would make them larger.
      #
      # Return Boolean.
      def can_compress?(mime_types)
        # The "charset" of a mime type is present if the value is
        # encoded text. We can check this value to see if the asset
        # can be compressed.
        #
        # We also check against our list of non-text compressible mime types
        @charset || COMPRESSABLE_MIME_TYPES.include?(@content_type)
      end

      # Private: Opposite of `can_compress?`.
      #
      # Returns Boolean.
      def cannot_compress?(mime_types)
        !can_compress?(mime_types)
      end

      # Private: Generates a gzipped file based off of reference asset.
      #
      # Compresses the target asset's contents and puts it into a file with
      # the same name plus a `.gz` extension in the same folder as the original.
      # Does not modify the target asset.
      #
      # Returns nothing.
      def compress(target)
        mtime = PathUtils.stat(target).mtime
        PathUtils.atomic_write("#{target}.gz") do |f|
          gz = Zlib::GzipWriter.new(f, Zlib::BEST_COMPRESSION)
          gz.mtime = mtime
          gz.write(@source)
          gz.close

          File.utime(mtime, mtime, f.path)
        end

        nil
      end
    end
  end
end
