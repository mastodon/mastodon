module ChunkyPNG
  class Canvas
    
    # Methods for decoding and encoding Adam7 interlacing.
    #
    # Adam7 interlacing extracts 7 pass images out of a single image, that can be encoded to a
    # stream separately so the image can be built up progressively. The module is included into
    # ChunkyPNG canvas and is used to extract the pass images from the original image, or to
    # reconstruct an original image from separate pass images.
    module Adam7Interlacing
      
      # Returns an array with the x-shift, x-offset, y-shift and y-offset for the requested pass.
      # @param [Integer] pass The pass number, should be in 0..6.
      def adam7_multiplier_offset(pass)
        [3 - (pass >> 1), (pass & 1 == 0) ? 0 : 8 >> ((pass + 1) >> 1),
         pass == 0 ? 3 : 3 - ((pass - 1) >> 1), (pass == 0 || pass & 1 == 1) ? 0 : 8 >> (pass >> 1)]
      end

      # Returns the pixel dimensions of the requested pass.
      # @param [Integer] pass The pass number, should be in 0..6.
      # @param [Integer] original_width The width of the original image.
      # @param [Integer] original_height The height of the original image.
      def adam7_pass_size(pass, original_width, original_height)
        x_shift, x_offset, y_shift, y_offset = adam7_multiplier_offset(pass)
        [ (original_width  - x_offset + (1 << x_shift) - 1) >> x_shift,
          (original_height - y_offset + (1 << y_shift) - 1) >> y_shift]
      end
      
      # Returns an array of the dimension of all the pass images.
      # @param [Integer] original_width The width of the original image.
      # @param [Integer] original_height The height of the original image.
      # @return [Array<Array<Integer>>] Returns an array with 7 pairs of dimensions.
      # @see #adam7_pass_size
      def adam7_pass_sizes(original_width, original_height)
        (0...7).map { |pass| adam7_pass_size(pass, original_width, original_height) }
      end

      # Merges a pass image into a total image that is being constructed.
      # @param [Integer] pass The pass number, should be in 0..6.
      # @param [ChunkyPNG::Canvas] canvas The image that is being constructed.
      # @param [ChunkyPNG::Canvas] subcanvas The pass image that should be merged
      def adam7_merge_pass(pass, canvas, subcanvas)
        x_shift, x_offset, y_shift, y_offset = adam7_multiplier_offset(pass)
        for y in 0...subcanvas.height do
          for x in 0...subcanvas.width do
            new_x = (x << x_shift) | x_offset
            new_y = (y << y_shift) | y_offset
            canvas[new_x, new_y] = subcanvas[x, y]
          end
        end
      end
      
      # Extracts a pass from a complete image
      # @param [Integer] pass The pass number, should be in 0..6.
      # @param [ChunkyPNG::Canvas] canvas The image that is being deconstructed.
      # @return [ChunkyPNG::Canvas] The extracted pass image.
      def adam7_extract_pass(pass, canvas)
        x_shift, x_offset, y_shift, y_offset = adam7_multiplier_offset(pass)
        sm_pixels = []
        
        y_offset.step(canvas.height - 1, 1 << y_shift) do |y|
          x_offset.step(canvas.width - 1, 1 << x_shift) do |x|
            sm_pixels << canvas[x, y]
          end
        end
        
        new_canvas_args = adam7_pass_size(pass, canvas.width, canvas.height) + [sm_pixels]
        ChunkyPNG::Canvas.new(*new_canvas_args)
      end
    end
  end
end
