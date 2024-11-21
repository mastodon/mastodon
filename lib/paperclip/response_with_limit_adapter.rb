# frozen_string_literal: true

module Paperclip
  class ResponseWithLimitAdapter < AbstractAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        target.is_a?(ResponseWithLimit)
      end
    end

    def initialize(target, options = {})
      super
      cache_current_values
    end

    private

    def cache_current_values
      @target.response.require_limit_not_exceeded!(@target.limit)

      @original_filename = truncated_filename
      @tempfile = copy_to_tempfile(@target)
      @content_type = ContentTypeDetector.new(@tempfile.path).detect
      @size = File.size(@tempfile)
    end

    def copy_to_tempfile(source)
      bytes_read = 0

      source.response.body.each do |chunk|
        bytes_read += chunk.bytesize
        raise Mastodon::LengthValidationError, "Body size exceeds limit of #{source.limit}" if bytes_read > source.limit

        destination.write(chunk)
        chunk.clear
      end

      destination.rewind
      destination
    rescue
      destination.close(true)
      raise
    ensure
      source.response.connection.close
    end

    def truncated_filename
      filename = filename_from_content_disposition.presence || filename_from_path.presence || 'data'
      extension = File.extname(filename)
      basename = File.basename(filename, extension)
      [basename[...20], extension[..4]].compact_blank.join
    end

    def filename_from_content_disposition
      disposition = @target.response.headers['content-disposition']
      disposition&.match(/filename="([^"]*)"/)&.captures&.first
    end

    def filename_from_path
      @target.response.uri.path.split('/').last
    end
  end
end
