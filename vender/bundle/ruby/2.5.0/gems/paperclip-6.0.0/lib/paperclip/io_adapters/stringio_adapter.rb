module Paperclip
  class StringioAdapter < AbstractAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        StringIO === target
      end
    end

    def initialize(target, options = {})
      super
      cache_current_values
    end

    attr_writer :content_type

    private

    def cache_current_values
      self.original_filename = @target.original_filename if @target.respond_to?(:original_filename)
      self.original_filename ||= "data"
      @tempfile = copy_to_tempfile(@target)
      @content_type = ContentTypeDetector.new(@tempfile.path).detect
      @size = @target.size
    end

    def copy_to_tempfile(source)
      while data = source.read(16*1024)
        destination.write(data)
      end
      destination.rewind
      destination
    end
  end
end

Paperclip::StringioAdapter.register
