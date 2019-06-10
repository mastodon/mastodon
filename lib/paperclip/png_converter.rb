# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert images to JPG (except for transparent PNG)
  class PngConverter < Processor
    def make
      opaque = identify('-format "%[opaque]" :src', src: File.expand_path(file.path)).strip.downcase

      if opaque == 'true'
        basename = File.basename(file.path, File.extname(file.path))
        dst_name = basename << ".jpg"

        dst = Paperclip::TempfileFactory.new.generate(dst_name)

        convert(':src :dst',
                src: File.expand_path(file.path),
                dst: File.expand_path(dst.path))

        if @file.size > dst.size
          attachment.instance.file_content_type = 'image/jpeg'
          return dst
        end
      end
      @file
    end
  end
end
