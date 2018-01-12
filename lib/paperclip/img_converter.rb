module Paperclip
  class ImgConverter < Processor
    def make
      if identify('-format "%[opaque]" :src', src: File.expand_path(file.path)).strip == 'true'
         basename = File.basename(file.path, File.extname(file.path))
        dst_name = basename << ".jpg"

        dst = Paperclip::TempfileFactory.new.generate(dst_name)

        convert(':src :dst',
                src: File.expand_path(file.path),
                dst: File.expand_path(dst.path))

        src_filesize = identify('-format %b :src', src: File.expand_path(file.path)).to_i
        dst_filesize = identify('-format %b :dst', dst: File.expand_path(dst.path)).to_i
        if src_filesize > dst_filesize
          attachment.instance.file_content_type = 'image/jpeg'
          return dst
        end
      end
      @file
    end
  end
end
