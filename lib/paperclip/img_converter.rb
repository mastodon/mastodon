# frozen_string_literal: true

module Paperclip
  class ImgConverter < Paperclip::Processor
    def initialize(file, options = {}, attachment = nil)
      super

      @current_format = File.extname(@file.path)
      @basename       = File.basename(@file.path, @current_format)
    end

    def make
      dst_format, dst_content_type = opaque? ? ['jpg', 'image/jpeg'] : ['png', 'image/png']
      dst_name = "#{@basename}.#{dst_format}"

      attachment.instance.file_file_name = dst_name
      attachment.instance.file_content_type = dst_content_type

      options[:format] = dst_format
      options[:content_type] = dst_content_type

      dst = Paperclip::TempfileFactory.new.generate(dst_name)
      convert(':src :dst', src: File.expand_path(@file.path), dst: File.expand_path(dst.path))

      dst
    end

    private

    def opaque?
      identify('-format "%[opaque]" :src', src: File.expand_path(@file.path)).strip.downcase == 'true'
    end
  end
end
