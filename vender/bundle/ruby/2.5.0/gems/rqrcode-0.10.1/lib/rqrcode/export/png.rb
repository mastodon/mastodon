require 'chunky_png'

# This class creates PNG files.
# Code from: https://github.com/DCarper/rqrcode
module RQRCode
  module Export
    module PNG

      # Render the PNG from the Qrcode.
      #
      # There are two sizing algoritams.
      #
      # - Original that can result in blurry and hard to scan images
      # - Google's Chart API inspired sizing that resizes the module size to fit within the given image size.
      # 
      # The Googleis one will be used when no options are given or when the new size option is used.
      #
      # Options: 
      # fill  - Background ChunkyPNG::Color, defaults to 'white'
      # color - Foreground ChunkyPNG::Color, defaults to 'black'
      #
      # *Googleis*    
      # size            - Total size of PNG in pixels. The module size is calculated so it fits. (defaults to 90)
      # border_modules  - Width of white border around in modules. (defaults to 4).
      #
      #  -- DONT USE border_modules OPTION UNLESS YOU KNOW ABOUT THE QUIET ZONE NEEDS OF QR CODES --
      #
      # *Original*
      # module_px_size  - Image size, in pixels.
      # border - Border thickness, in pixels
      #
      # It first creates an image where 1px = 1 module, then resizes.
      # Defaults to 90x90 pixels, customizable by option.
      #
      def as_png(options = {})

        default_img_options = {
          :resize_gte_to => false,
          :resize_exactly_to => false,
          :fill => 'white',
          :color => 'black',
          :size => 120,
          :border_modules => 4,
          :file => false,
          :module_px_size => 6
        }
        
        googleis = options.length == 0 || (options[:size] != nil)
        
        options = default_img_options.merge(options) # reverse_merge

        fill   = ChunkyPNG::Color(options[:fill])
        color  = ChunkyPNG::Color(options[:color])
        output_file = options[:file]
        
        module_px_size = nil
        border_px = nil
        png = nil
        
        if googleis
          total_image_size = options[:size]
          border_modules = options[:border_modules]

          module_px_size = (total_image_size.to_f / (self.module_count + 2 * border_modules).to_f).floor.to_i

          img_size = module_px_size * self.module_count

          remaining = total_image_size - img_size
          border_px = (remaining / 2.0).floor.to_i

          png = ChunkyPNG::Image.new(total_image_size, total_image_size, fill)
        else
          border = options[:border_modules]
          total_border = border * 2
          module_px_size = if options[:resize_gte_to]
            (options[:resize_gte_to].to_f / (self.module_count + total_border).to_f).ceil.to_i
          else
            options[:module_px_size]
          end
          border_px = border *  module_px_size
          total_border_px = border_px * 2
          resize_to = options[:resize_exactly_to]

          img_size = module_px_size * self.module_count
          total_img_size = img_size + total_border_px

          png = ChunkyPNG::Image.new(total_img_size, total_img_size, fill)
        end

        self.modules.each_index do |x|
          self.modules.each_index do |y|
            if self.dark?(x, y)
              (0...module_px_size).each do |i|
                (0...module_px_size).each do |j|
                  png[(y * module_px_size) + border_px + j , (x * module_px_size) + border_px + i] = color
                end
              end
            end
          end
        end
        
        if !googleis && resize_to
          png = png.resize(resize_to, resize_to)  
        end


        if output_file
          png.save(output_file,{ :color_mode => ChunkyPNG::COLOR_GRAYSCALE, :bit_depth =>1})
        end
        png
      end

    end
  end
end

RQRCode::QRCode.send :include, RQRCode::Export::PNG
