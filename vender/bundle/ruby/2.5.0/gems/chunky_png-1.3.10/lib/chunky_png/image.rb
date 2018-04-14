module ChunkyPNG

  # ChunkyPNG::Image is an extension of the {ChunkyPNG::Canvas} class, that
  # also includes support for metadata.
  #
  # @see ChunkyPNG::Canvas
  class Image < Canvas

    # The minimum size of bytes the value of a metadata field should be before compression
    # is enabled for the chunk.
    METADATA_COMPRESSION_TRESHOLD = 300
    
    # @return [Hash] The hash of metadata fields for this PNG image.
    attr_accessor :metadata
    
    # Initializes a new ChunkyPNG::Image instance.
    # @param [Integer] width The width of the new image.
    # @param [Integer] height The height of the new image.
    # @param [Integer] bg_color The background color of the new image.
    # @param [Hash] metadata A hash of metadata fields and values for this image.
    # @see ChunkyPNG::Canvas#initialize
    def initialize(width, height, bg_color = ChunkyPNG::Color::TRANSPARENT, metadata = {})
      super(width, height, bg_color)
      @metadata = metadata
    end
    
    # Initializes a copy of another ChunkyPNG::Image instance.
    #
    # @param [ChunkyPNG::Image] other The other image to copy.
    def initialize_copy(other)
      super(other)
      @metadata = other.metadata
    end
    
    # Returns the metadata for this image as PNG chunks.
    #
    # Chunks will either be of the {ChunkyPNG::Chunk::Text} type for small
    # values (in bytes), or of the {ChunkyPNG::Chunk::CompressedText} type
    # for values that are larger in size.
    #
    # @return [Array<ChunkyPNG::Chunk>] An array of metadata chunks.
    # @see ChunkyPNG::Image::METADATA_COMPRESSION_TRESHOLD
    def metadata_chunks
      metadata.map do |key, value|
        if value.length >= METADATA_COMPRESSION_TRESHOLD
          ChunkyPNG::Chunk::CompressedText.new(key, value)
        else
          ChunkyPNG::Chunk::Text.new(key, value)
        end
      end
    end
    
    # Encodes the image to a PNG datastream for saving to disk or writing to an IO stream.
    #
    # Besides encoding the canvas, it will also encode the metadata fields to text chunks.
    #
    # @param [Hash] constraints The constraints to use when encoding the canvas.
    # @return [ChunkyPNG::Datastream] The datastream that contains this image.
    # @see ChunkyPNG::Canvas::PNGEncoding#to_datastream
    # @see #metadata_chunks
    def to_datastream(constraints = {})
      ds = super(constraints)
      ds.other_chunks += metadata_chunks
      return ds
    end
    
    # Reads a ChunkyPNG::Image instance from a data stream.
    #
    # Besides decoding the canvas, this will also read the metadata fields
    # from the datastream.
    #
    # @param [ChunkyPNG::Datastream] The datastream to read from.
    def self.from_datastream(ds)
      image = super(ds)
      image.metadata = ds.metadata
      return image
    end
  end
end
