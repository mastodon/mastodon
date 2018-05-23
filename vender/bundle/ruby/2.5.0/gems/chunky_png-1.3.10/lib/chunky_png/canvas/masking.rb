module ChunkyPNG
  class Canvas
    
    # The ChunkyPNG::Canvas::Masking module defines methods to perform masking
    # and theming operations on a {ChunkyPNG::Canvas}. The module is included into the Canvas class so all
    # these methods are available on every canvas.
    #
    # @see ChunkyPNG::Canvas
    module Masking

      # Creates a new image, based on the current image but with a new theme color.
      #
      # This method will replace one color in an image with another image. This is done by
      # first extracting the pixels with a color close to the original theme color as a mask
      # image, changing the color of this mask image and then apply it on the original image.
      #
      # Mask extraction works best when the theme colored pixels are clearly distinguishable
      # from a background color (preferably white). You can set a tolerance level to influence
      # the extraction process.
      #
      # @param [Integer] old_theme_color The original theme color in this image.
      # @param [Integer] new_theme_color The color to replace the old theme color with.
      # @param [Integer] bg_color The background color on which the theme colored pixels are placed.
      # @param [Integer] tolerance The tolerance level to use when extracting the mask image. Five is 
      #    the default; increase this if the masked image does not extract all the required pixels, 
      #    decrease it if too many pixels get extracted.
      # @return [ChunkyPNG::Canvas] Returns itself, but with the theme colored pixels changed.
      # @see #change_theme_color!
      # @see #change_mask_color!
      def change_theme_color!(old_theme_color, new_theme_color, bg_color = ChunkyPNG::Color::WHITE, tolerance = 5)
        base, mask = extract_mask(old_theme_color, bg_color, tolerance)
        mask.change_mask_color!(new_theme_color)
        self.replace!(base.compose!(mask))
      end
      
      # Creates a base image and a mask image from an original image that has a particular theme color.
      # This can be used to easily change a theme color in an image.
      #
      # It will extract all the pixels that look like the theme color (with a tolerance level) and put
      # these in a mask image. All the other pixels will be stored in a base image. Both images will be
      # of the exact same size as the original image. The original image will be left untouched.
      #
      # The color of the mask image can be changed with {#change_mask_color!}. This new mask image can 
      # then be composed upon the base image to create an image with a new theme color. A call to 
      # {#change_theme_color!} will perform this in one go.
      #
      # @param [Integer] mask_color The current theme color.
      # @param [Integer] bg_color The background color on which the theme colored pixels are applied.
      # @param [Integer] tolerance The tolerance level to use when extracting the mask image. Five is 
      #    the default; increase this if the masked image does not extract all the required pixels, 
      #    decrease it if too many pixels get extracted.
      # @return [Array<ChunkyPNG::Canvas, ChunkyPNG::Canvas>] An array with the base canvas and the mask 
      #    canvas as elements.
      # @see #change_theme_color!
      # @see #change_mask_color!
      def extract_mask(mask_color, bg_color = ChunkyPNG::Color::WHITE, tolerance = 5)
        base_pixels = []
        mask_pixels = []

        pixels.each do |pixel|
          if ChunkyPNG::Color.alpha_decomposable?(pixel, mask_color, bg_color, tolerance)
            mask_pixels << ChunkyPNG::Color.decompose_color(pixel, mask_color, bg_color, tolerance)
            base_pixels << bg_color
          else
            mask_pixels << (mask_color & 0xffffff00)
            base_pixels << pixel
          end
        end
        
        [ self.class.new(width, height, base_pixels), self.class.new(width, height, mask_pixels) ]
      end
      
      # Changes the color of a mask image.
      #
      # This method works on a canvas extracted out of another image using the {#extract_mask} method.
      # It can then be applied on the extracted base image. See {#change_theme_color!} to perform
      # these operations in one go.
      #
      # @param [Integer] new_color The color to replace the original mask color with.
      # @raise [ChunkyPNG::ExpectationFailed] when this canvas is not a mask image, i.e. its palette
      #    has more than once color, disregarding transparency.
      # @see #change_theme_color!
      # @see #extract_mask
      def change_mask_color!(new_color)
        raise ChunkyPNG::ExpectationFailed, "This is not a mask image!" if palette.opaque_palette.size != 1
        pixels.map! { |pixel| (new_color & 0xffffff00) | ChunkyPNG::Color.a(pixel) }
        self
      end
    end
  end
end
