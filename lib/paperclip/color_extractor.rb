# frozen_string_literal: true

require 'mime/types/columnar'

module Paperclip
  class ColorExtractor < Paperclip::Processor
    MIN_CONTRAST        = 3.0
    ACCENT_MIN_CONTRAST = 2.0
    FREQUENCY_THRESHOLD = 0.01
    BINS = 10

    def make
      background_palette, foreground_palette = Rails.configuration.x.use_vips ? palettes_from_libvips : palettes_from_imagemagick

      background_color   = background_palette.first || foreground_palette.first
      foreground_colors  = []

      return @file if background_color.nil?

      max_distance       = 0
      max_distance_color = nil

      foreground_palette.each do |color|
        distance = ColorDiff.between(background_color, color)
        contrast = w3c_contrast(background_color, color)

        if distance > max_distance && contrast >= ACCENT_MIN_CONTRAST
          max_distance = distance
          max_distance_color = color
        end
      end

      foreground_colors << max_distance_color unless max_distance_color.nil?

      max_distance       = 0
      max_distance_color = nil

      foreground_palette.each do |color|
        distance = ColorDiff.between(background_color, color)
        contrast = w3c_contrast(background_color, color)

        if distance > max_distance && contrast >= MIN_CONTRAST && !foreground_colors.include?(color)
          max_distance = distance
          max_distance_color = color
        end
      end

      foreground_colors << max_distance_color unless max_distance_color.nil?

      # If we don't have enough colors for accent and foreground, generate
      # new ones by manipulating the background color
      (2 - foreground_colors.size).times do |i|
        foreground_colors << lighten_or_darken(background_color, 35 + (i * 15))
      end

      # We want the color with the highest contrast to background to be the foreground one,
      # and the one with the highest saturation to be the accent one
      foreground_color = foreground_colors.max_by { |rgb| w3c_contrast(background_color, rgb) }
      accent_color     = foreground_colors.max_by { |rgb| rgb_to_hsl(rgb.r, rgb.g, rgb.b)[1] }

      meta = {
        colors: {
          background: rgb_to_hex(background_color),
          foreground: rgb_to_hex(foreground_color),
          accent: rgb_to_hex(accent_color),
        },
      }

      attachment.instance.file.instance_write(:meta, (attachment.instance.file.instance_read(:meta) || {}).merge(meta))

      @file
    rescue Vips::Error => e
      raise Paperclip::Error, "Error while extracting colors for #{@basename}: #{e}"
    end

    private

    def palettes_from_libvips
      image = downscaled_image
      block_edge_dim = (image.height * 0.25).floor
      line_edge_dim = (image.width * 0.25).floor

      edge_image = begin
        top = image.crop(0, 0, image.width, block_edge_dim)
        bottom = image.crop(0, image.height - block_edge_dim, image.width, block_edge_dim)
        left = image.crop(0, block_edge_dim, line_edge_dim, image.height - (block_edge_dim * 2))
        right = image.crop(image.width - line_edge_dim, block_edge_dim, line_edge_dim, image.height - (block_edge_dim * 2))
        top.join(bottom, :vertical).join(left, :horizontal).join(right, :horizontal)
      end

      background_palette = palette_from_image(edge_image)
      foreground_palette = palette_from_image(image)
      [background_palette, foreground_palette]
    end

    def palettes_from_imagemagick
      depth = 8

      # Determine background palette by getting colors close to the image's edge only
      background_palette = palette_from_im_histogram(convert(':source -alpha set -gravity Center -region 75%x75% -fill None -colorize 100% -alpha transparent +region -format %c -colors :quantity -depth :depth histogram:info:', source: File.expand_path(@file.path), quantity: 10, depth: depth), 10)

      # Determine foreground palette from the whole image
      foreground_palette = palette_from_im_histogram(convert(':source -format %c -colors :quantity -depth :depth histogram:info:', source: File.expand_path(@file.path), quantity: 10, depth: depth), 10)
      [background_palette, foreground_palette]
    end

    def downscaled_image
      image = Vips::Image.new_from_file(@file.path, access: :random).thumbnail_image(100)

      image.colourspace(:srgb).extract_band(0, n: 3)
    end

    def palette_from_image(image)
      # `hist_find_ndim` will create a BINS×BINS×BINS 3D histogram of the image
      # represented as an image of size BINS×BINS with `BINS` bands.
      # The number of occurrences of a color (r, g, b) is thus encoded in band `b` at pixel position `(r, g)`
      histogram = image.hist_find_ndim(bins: BINS)

      # With `bandunfold`, we get back to a (BINS*BINS)×BINS 2D image with a single band.
      # The number of occurrences of a color (r, g, b) is thus encoded at pixel position `(r * BINS + b, g)`
      histogram = histogram.bandunfold

      _, colors = histogram.max(size: 10, out_array: true, x_array: true, y_array: true)

      colors['x_array'].zip(colors['y_array']).map do |x, y|
        rgb_from_hist_xy(x, y)
      end.flatten.reverse
    end

    # rubocop:disable Naming/MethodParameterName
    def rgb_from_hist_xy(x, y)
      r = ((x / BINS) + 0.5) * 256 / BINS
      g = (y + 0.5) * 256 / BINS
      b = ((x % BINS) + 0.5) * 256 / BINS
      ColorDiff::Color::RGB.new(r, g, b)
    end

    def w3c_contrast(color1, color2)
      luminance1 = (color1.to_xyz.y * 0.01) + 0.05
      luminance2 = (color2.to_xyz.y * 0.01) + 0.05

      if luminance1 > luminance2
        luminance1 / luminance2
      else
        luminance2 / luminance1
      end
    end

    def rgb_to_hsl(r, g, b)
      r /= 255.0
      g /= 255.0
      b /= 255.0
      max = [r, g, b].max
      min = [r, g, b].min
      h = (max + min) / 2.0
      s = (max + min) / 2.0
      l = (max + min) / 2.0

      if max == min
        h = 0
        s = 0 # achromatic
      else
        d = max - min
        s = l >= 0.5 ? d / (2.0 - max - min) : d / (max + min)

        case max
        when r
          h = ((g - b) / d) + (g < b ? 6.0 : 0)
        when g
          h = ((b - r) / d) + 2.0
        when b
          h = ((r - g) / d) + 4.0
        end

        h /= 6.0
      end

      [(h * 360).round, (s * 100).round, (l * 100).round]
    end

    def hue_to_rgb(p, q, t)
      t += 1 if t.negative?
      t -= 1 if t > 1

      return (p + ((q - p) * 6 * t)) if t < 1 / 6.0
      return q if t < 1 / 2.0
      return (p + ((q - p) * ((2 / 3.0) - t) * 6)) if t < 2 / 3.0

      p
    end

    def hsl_to_rgb(h, s, l)
      h /= 360.0
      s /= 100.0
      l /= 100.0

      r = 0.0
      g = 0.0
      b = 0.0

      if s.zero?
        r = l.to_f
        g = l.to_f
        b = l.to_f # achromatic
      else
        q = l < 0.5 ? l * (s + 1) : l + s - (l * s)
        p = (2 * l) - q
        r = hue_to_rgb(p, q, h + (1 / 3.0))
        g = hue_to_rgb(p, q, h)
        b = hue_to_rgb(p, q, h - (1 / 3.0))
      end

      [(r * 255).round, (g * 255).round, (b * 255).round]
    end
    # rubocop:enable Naming/MethodParameterName

    def lighten_or_darken(color, by)
      hue, saturation, light = rgb_to_hsl(color.r, color.g, color.b)

      light = if light < 50
                [100, light + by].min
              else
                [0, light - by].max
              end

      ColorDiff::Color::RGB.new(*hsl_to_rgb(hue, saturation, light))
    end

    def palette_from_im_histogram(result, quantity)
      frequencies       = result.scan(/([0-9]+):/).flatten.map(&:to_f)
      hex_values        = result.scan(/\#([0-9A-Fa-f]{6,8})/).flatten
      total_frequencies = frequencies.sum.to_f

      frequencies.map.with_index { |f, i| [f / total_frequencies, hex_values[i]] }
                 .sort_by { |r| -r[0] }
                 .reject { |r| r[1].size == 8 && r[1].end_with?('00') }
                 .map { |r| ColorDiff::Color::RGB.new(*r[1][0..5].scan(/../).map { |c| c.to_i(16) }) }
                 .slice(0, quantity)
    end

    def rgb_to_hex(rgb)
      format('#%02x%02x%02x', rgb.r, rgb.g, rgb.b)
    end
  end
end
