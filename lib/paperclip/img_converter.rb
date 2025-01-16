# frozen_string_literal: true

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert images to JPG (except for transparent PNG)
  class ImgConverter < Processor
    def make
      return convert_image_with_vips if Rails.configuration.x.use_vips

      convert_image_with_imagemagick
    end

    def convert_image_with_vips
      src_path = File.expand_path(file.path)
      image = new_vipsimage_from_file(src_path)

      if opaque?(image)
        basename = File.basename(file.path, File.extname(file.path))
        dst_name = basename << '.jpeg'

        dst = Paperclip::TempfileFactory.new.generate(dst_name)

        new_vipsimage_from_file(src_path).write_to_file(File.expand_path(dst.path), **save_options)

        if @file.size > dst.size
          attachment.instance.file_file_name = "#{File.basename(attachment.instance.file_file_name, '.*')}.jpeg"
          attachment.instance.file_content_type = 'image/jpeg'
          return dst
        end
      end
      @file
    end

    def new_vipsimage_from_file(src_path)
      Vips::Image.new_from_file(preserve_animation? ? "#{src_path}[n=-1]" : src_path, access: :sequential)
    end

    def convert_image_with_imagemagick
      opaque = identify('-format "%[opaque]" :src', src: File.expand_path(file.path)).strip.downcase

      if opaque == 'true'
        basename = File.basename(file.path, File.extname(file.path))
        dst_name = basename << '.jpeg'

        dst = Paperclip::TempfileFactory.new.generate(dst_name)

        convert(':src :dst',
                src: File.expand_path(file.path),
                dst: File.expand_path(dst.path))

        if @file.size > dst.size
          attachment.instance.file_file_name = "#{File.basename(attachment.instance.file_file_name, '.*')}.jpeg"
          attachment.instance.file_content_type = 'image/jpeg'
          return dst
        end
      end
      @file
    end

    def opaque?(image)
      return true unless has_alpha_channel?(image)

      image[image.bands - 1].min == 255
    end

    def has_alpha_channel?(image) # rubocop:disable Naming/PredicateName
      image.bands == 2 or (image.bands == 4 and image.interpretation != 'cmyk') or image.bands > 4
    end

    def preserve_animation?
      @format == 'gif' || (@format.blank? && @current_format == '.gif')
    end

    def save_options
      case @format
      when 'jpg'
        { Q: 90, interlace: true }
      else
        {}
      end
    end
  end
end
