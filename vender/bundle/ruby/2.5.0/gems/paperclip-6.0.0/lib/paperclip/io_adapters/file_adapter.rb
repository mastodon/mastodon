module Paperclip
  class FileAdapter < AbstractAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        File === target || ::Tempfile === target
      end
    end

    def initialize(target, options = {})
      super
      cache_current_values
    end

    private

    def cache_current_values
      if @target.respond_to?(:original_filename)
        self.original_filename = @target.original_filename
      end
      self.original_filename ||= File.basename(@target.path)
      @tempfile = copy_to_tempfile(@target)
      @content_type = ContentTypeDetector.new(@target.path).detect
      @size = File.size(@target)
    end
  end
end

Paperclip::FileAdapter.register
