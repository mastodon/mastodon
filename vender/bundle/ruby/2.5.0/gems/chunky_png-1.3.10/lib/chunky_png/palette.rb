module ChunkyPNG
  # A palette describes the set of colors that is being used for an image.
  #
  # A PNG image can contain an explicit palette which defines the colors of
  # that image, but can also use an implicit palette, e.g. all truecolor colors
  # or all grayscale colors.
  #
  # This palette supports decoding colors from a palette if an explicit palette
  # is provided in a PNG datastream, and it supports encoding colors to an
  # explicit palette (stores as PLTE & tRNS chunks in a PNG file).
  #
  # @see ChunkyPNG::Color
  class Palette < SortedSet
    # Builds a new palette given a set (Enumerable instance) of colors.
    #
    # @param enum [Enumerable<Integer>] The set of colors to include in this
    #   palette.This Enumerable can contain duplicates.
    # @param decoding_map [Array] An array of colors in the exact order at
    #   which they appeared in the palette chunk, so that this array can be
    #   used for decoding.
    def initialize(enum, decoding_map = nil)
      super(enum)
      @decoding_map = decoding_map if decoding_map
    end

    # Builds a palette instance from a PLTE chunk and optionally a tRNS chunk
    # from a PNG datastream.
    #
    # This method will cerate a palette that is suitable for decoding an image.
    #
    # @param palette_chunk [ChunkyPNG::Chunk::Palette] The palette chunk to
    #   load from
    # @param transparency_chunk [ChunkyPNG::Chunk::Transparency, nil] The
    #   optional transparency chunk.
    # @return [ChunkyPNG::Palette] The loaded palette instance.
    # @see ChunkyPNG::Palette#can_decode?
    def self.from_chunks(palette_chunk, transparency_chunk = nil)
      return nil if palette_chunk.nil?

      decoding_map = []
      index = 0

      palatte_bytes = palette_chunk.content.unpack('C*')
      if transparency_chunk
        alpha_channel = transparency_chunk.content.unpack('C*')
      else
        alpha_channel = []
      end

      index = 0
      palatte_bytes.each_slice(3) do |bytes|
        bytes << alpha_channel.fetch(index, ChunkyPNG::Color::MAX)
        decoding_map << ChunkyPNG::Color.rgba(*bytes)
        index += 1
      end

      new(decoding_map, decoding_map)
    end

    # Builds a palette instance from a given canvas.
    # @param canvas [ChunkyPNG::Canvas] The canvas to create a palette for.
    # @return [ChunkyPNG::Palette] The palette instance.
    def self.from_canvas(canvas)
      # Although we don't need to call .uniq.sort before initializing, because
      # Palette subclasses SortedSet, we get significantly better performance
      # by doing so.
      new(canvas.pixels.uniq.sort)
    end

    # Builds a palette instance from a given set of pixels.
    # @param pixels [Enumerable<Integer>] An enumeration of pixels to create a
    #   palette for
    # @return [ChunkyPNG::Palette] The palette instance.
    def self.from_pixels(pixels)
      new(pixels)
    end

    # Checks whether the size of this palette is suitable for indexed storage.
    # @return [true, false] True if the number of colors in this palette is at
    #   most 256.
    def indexable?
      size <= 256
    end

    # Check whether this palette only contains opaque colors.
    # @return [true, false] True if all colors in this palette are opaque.
    # @see ChunkyPNG::Color#opaque?
    def opaque?
      all? { |color| Color.opaque?(color) }
    end

    # Check whether this palette only contains grayscale colors.
    # @return [true, false] True if all colors in this palette are grayscale
    #   teints.
    # @see ChunkyPNG::Color#grayscale??
    def grayscale?
      all? { |color| Color.grayscale?(color) }
    end

    # Check whether this palette only contains bacl and white.
    # @return [true, false] True if all colors in this palette are grayscale
    #   teints.
    # @see ChunkyPNG::Color#grayscale??
    def black_and_white?
      entries == [ChunkyPNG::Color::BLACK, ChunkyPNG::Color::WHITE]
    end

    # Returns a palette with all the opaque variants of the colors in this
    # palette.
    # @return [ChunkyPNG::Palette] A new Palette instance with only opaque
    #   colors.
    # @see ChunkyPNG::Color#opaque!
    def opaque_palette
      self.class.new(map { |c| ChunkyPNG::Color.opaque!(c) })
    end

    # Checks whether this palette is suitable for decoding an image from a
    # datastream.
    #
    # This requires that the positions of the colors in the original palette
    # chunk is known, which is stored as an array in the +@decoding_map+
    # instance variable.
    #
    # @return [true, false] True if a decoding map was built when this palette
    #   was loaded.
    def can_decode?
      !@decoding_map.nil?
    end

    # Checks whether this palette is suitable for encoding an image from to
    # datastream.
    #
    # This requires that the position of the color in the future palette chunk
    # is known, which is stored as a hash in the +@encoding_map+ instance
    # variable.
    #
    # @return [true, false] True if a encoding map was built when this palette
    #   was loaded.
    def can_encode?
      !@encoding_map.nil?
    end

    # Returns a color, given the position in the original palette chunk.
    # @param index [Integer] The 0-based position of the color in the palette.
    # @return [ChunkyPNG::Color] The color that is stored in the palette under
    #   the given index
    # @see ChunkyPNG::Palette#can_decode?
    def [](index)
      @decoding_map[index]
    end

    # Returns the position of a color in the palette
    # @param color [ChunkyPNG::Color] The color for which to look up the index.
    # @return [Integer] The 0-based position of the color in the palette.
    # @see ChunkyPNG::Palette#can_encode?
    def index(color)
      color.nil? ? 0 : @encoding_map[color]
    end

    # Creates a tRNS chunk that corresponds with this palette to store the
    # alpha channel of all colors.
    #
    # Note that this chunk can be left out of every color in the palette is
    # opaque, and the image is encoded using indexed colors.
    #
    # @return [ChunkyPNG::Chunk::Transparency] The tRNS chunk.
    def to_trns_chunk
      ChunkyPNG::Chunk::Transparency.new('tRNS', map { |c| ChunkyPNG::Color.a(c) }.pack('C*'))
    end

    # Creates a PLTE chunk that corresponds with this palette to store the r,
    # g, and b channels of all colors.
    #
    # @note A PLTE chunk should only be included if the image is encoded using
    #   index colors. After this chunk has been built, the palette becomes
    #   suitable for encoding an image.
    #
    # @return [ChunkyPNG::Chunk::Palette] The PLTE chunk.
    # @see ChunkyPNG::Palette#can_encode?
    def to_plte_chunk
      @encoding_map = {}
      colors        = []

      each_with_index do |color, index|
        @encoding_map[color] = index
        colors += ChunkyPNG::Color.to_truecolor_bytes(color)
      end

      ChunkyPNG::Chunk::Palette.new('PLTE', colors.pack('C*'))
    end

    # Determines the most suitable colormode for this palette.
    # @return [Integer] The colormode which would create the smallest possible
    #  file for images that use this exact palette.
    def best_color_settings
      if black_and_white?
        [ChunkyPNG::COLOR_GRAYSCALE, 1]
      elsif grayscale?
        if opaque?
          [ChunkyPNG::COLOR_GRAYSCALE, 8]
        else
          [ChunkyPNG::COLOR_GRAYSCALE_ALPHA, 8]
        end
      elsif indexable?
        [ChunkyPNG::COLOR_INDEXED, determine_bit_depth]
      elsif opaque?
        [ChunkyPNG::COLOR_TRUECOLOR, 8]
      else
        [ChunkyPNG::COLOR_TRUECOLOR_ALPHA, 8]
      end
    end

    # Determines the minimal bit depth required for an indexed image
    # @return [Integer] Number of bits per pixel, i.e. 1, 2, 4 or 8, or nil if
    #   this image cannot be saved as an indexed image.
    def determine_bit_depth
      case size
      when 1..2 then 1
      when 3..4 then 2
      when 5..16 then 4
      when 17..256 then 8
      else nil
      end
    end
  end
end
