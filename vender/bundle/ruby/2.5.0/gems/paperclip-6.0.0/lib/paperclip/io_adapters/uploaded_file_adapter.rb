module Paperclip
  class UploadedFileAdapter < AbstractAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        target.class.name.include?("UploadedFile")
      end
    end

    def initialize(target, options = {})
      super
      cache_current_values

      if @target.respond_to?(:tempfile)
        @tempfile = copy_to_tempfile(@target.tempfile)
      else
        @tempfile = copy_to_tempfile(@target)
      end
    end

    class << self
      attr_accessor :content_type_detector
    end

    private

    def cache_current_values
      self.original_filename = @target.original_filename
      @content_type = determine_content_type
      @size = File.size(@target.path)
    end

    def content_type_detector
      self.class.content_type_detector || Paperclip::ContentTypeDetector
    end

    def determine_content_type
      content_type = @target.content_type.to_s.strip
      if content_type_detector
        content_type = content_type_detector.new(@target.path).detect
      end
      content_type
    end
  end
end

Paperclip::UploadedFileAdapter.register
