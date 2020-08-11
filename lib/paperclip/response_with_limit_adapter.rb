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
      @original_filename = filename_from_content_disposition || filename_from_path || 'data'
      @size = @target.response.content_length
      @tempfile = copy_to_tempfile(@target)
      @content_type = @target.response.mime_type || ContentTypeDetector.new(@tempfile.path).detect
    end

    def copy_to_tempfile(source)
      bytes_read = 0

      source.response.body.each do |chunk|
        bytes_read += chunk.bytesize

        destination.write(chunk)
        chunk.clear

        raise Mastodon::LengthValidationError if bytes_read > source.limit
      end

      destination.rewind
      destination
    rescue Mastodon::LengthValidationError
      destination.close(true)
      raise
    ensure
      source.response.connection.close
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
