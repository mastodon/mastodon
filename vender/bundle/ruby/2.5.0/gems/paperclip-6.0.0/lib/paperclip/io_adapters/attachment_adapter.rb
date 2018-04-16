module Paperclip
  class AttachmentAdapter < AbstractAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        Paperclip::Attachment === target || Paperclip::Style === target
      end
    end

    def initialize(target, options = {})
      super
      @target, @style = case target
      when Paperclip::Attachment
        [target, :original]
      when Paperclip::Style
        [target.attachment, target.name]
      end

      cache_current_values
    end

    private

    def cache_current_values
      self.original_filename = @target.original_filename
      @content_type = @target.content_type
      @tempfile = copy_to_tempfile(@target)
      @size = @tempfile.size || @target.size
    end

    def copy_to_tempfile(source)
      if source.staged?
        link_or_copy_file(source.staged_path(@style), destination.path)
      else
        source.copy_to_local_file(@style, destination.path)
      end
      destination
    end
  end
end

Paperclip::AttachmentAdapter.register
