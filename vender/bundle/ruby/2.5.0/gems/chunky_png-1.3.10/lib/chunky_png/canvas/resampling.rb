


module ChunkyPNG
  class Canvas
    
    # The ChunkyPNG::Canvas::Resampling module defines methods to perform image resampling to 
    # a {ChunkyPNG::Canvas}.
    #
    # Currently, only the nearest neighbor algorithm is implemented. Bilinear and cubic
    # algorithms may be added later on.
    #
    # @see ChunkyPNG::Canvas
    module Resampling

      # Integer Interpolation between two values
      #
      # Used for generating indicies for interpolation (eg, nearest
      # neighbour).
      #
      # @param [Integer] width The width of the source 
      # @param [Integer] new_width The width of the destination
      # @return [Array<Integer>] An Array of Integer indicies
      def steps(width, new_width)
        indicies, residues = steps_residues(width, new_width)
        
        for i in 1..new_width
          indicies[i-1] = (indicies[i-1] + (residues[i-1] + 127)/255)
        end
        return indicies
      end

      # Fractional Interpolation between two values
      #
      # Used for generating values for interpolation (eg, bilinear).
      # Produces both the indices and the interpolation factors (residues).
      #
      # @param [Integer] width The width of the source
      # @param [Integer] new_width The width of the destination
      # @return [Array<Integer>, Array<Integer>] Two arrays of indicies and residues
      def steps_residues(width, new_width)
        indicies = Array.new(new_width, obj=nil)
        residues = Array.new(new_width, obj=nil)
        
        # This works by accumulating the fractional error and
        # overflowing when necessary.

        # We use mixed number arithmetic with a denominator of
        # 2 * new_width
        base_step = width / new_width
        err_step = (width % new_width) << 1
        denominator = (new_width) << 1
                
        # Initial pixel
        index = (width - new_width) / denominator
        err = (width - new_width) % denominator

        for i in 1..new_width
          indicies[i-1] = index
          residues[i-1] = (255.0 * err.to_f / denominator.to_f).round

          index += base_step
          err += err_step
          if err >= denominator
            index += 1
            err -= denominator
          end
        end

        return indicies, residues
      end

      
      # Resamples the canvas using nearest neighbor interpolation.
      # @param [Integer] new_width The width of the resampled canvas.
      # @param [Integer] new_height The height of the resampled canvas.
      # @return [ChunkyPNG::Canvas] A new canvas instance with the resampled pixels.
      def resample_nearest_neighbor!(new_width, new_height)
        steps_x = steps(width, new_width)
        steps_y = steps(height, new_height)


        pixels = Array.new(new_width*new_height)
        i = 0
        for y in steps_y
          for x in steps_x
            pixels[i] = get_pixel(x, y)
            i += 1
          end
        end
        
        replace_canvas!(new_width.to_i, new_height.to_i, pixels)
      end
      
      def resample_nearest_neighbor(new_width, new_height)
        dup.resample_nearest_neighbor!(new_width, new_height)
      end

      # Resamples the canvas with bilinear interpolation.
      # @param [Integer] new_width The width of the resampled canvas.
      # @param [Integer] new_height The height of the resampled canvas.
      # @return [ChunkyPNG::Canvas] A new canvas instance with the resampled pixels.
      def resample_bilinear!(new_width, new_height)
        index_x, interp_x = steps_residues(width, new_width)
        index_y, interp_y = steps_residues(height, new_height)

        pixels = Array.new(new_width*new_height)
        i = 0
        for y in 1..new_height
          # Clamp the indicies to the edges of the image
          y1 = [index_y[y-1], 0].max
          y2 = [index_y[y-1] + 1, height - 1].min
          y_residue = interp_y[y-1]

          for x in 1..new_width
            # Clamp the indicies to the edges of the image
            x1 = [index_x[x-1], 0].max
            x2 = [index_x[x-1] + 1, width - 1].min
            x_residue = interp_x[x-1]

            pixel_11 = get_pixel(x1, y1)
            pixel_21 = get_pixel(x2, y1)
            pixel_12 = get_pixel(x1, y2)
            pixel_22 = get_pixel(x2, y2)

            # Interpolate by Row
            pixel_top = ChunkyPNG::Color.interpolate_quick(pixel_21, pixel_11, x_residue)
            pixel_bot = ChunkyPNG::Color.interpolate_quick(pixel_22, pixel_12, x_residue)

            # Interpolate by Column

            pixels[i] = ChunkyPNG::Color.interpolate_quick(pixel_bot, pixel_top, y_residue)
            i += 1
          end
        end
        replace_canvas!(new_width.to_i, new_height.to_i, pixels)
      end

      def resample_bilinear(new_width, new_height)
        dup.resample_bilinear!(new_width, new_height)
      end
      
      alias_method :resample, :resample_nearest_neighbor
      alias_method :resize, :resample
    end
  end
end
