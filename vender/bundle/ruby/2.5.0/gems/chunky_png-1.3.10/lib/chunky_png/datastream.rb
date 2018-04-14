module ChunkyPNG

  # The Datastream class represents a PNG formatted datastream. It supports
  # both reading from and writing to strings, streams and files.
  #
  # A PNG datastream begins with the PNG signature, and then contains multiple
  # chunks, starting with a header (IHDR) chunk and finishing with an end
  # (IEND) chunk.
  #
  # @see ChunkyPNG::Chunk
  class Datastream

    # The signature that each PNG file or stream should begin with.
    SIGNATURE = ChunkyPNG.force_binary([137, 80, 78, 71, 13, 10, 26, 10].pack('C8'))

    # The header chunk of this datastream.
    # @return [ChunkyPNG::Chunk::Header]
    attr_accessor :header_chunk

    # All other chunks in this PNG file.
    # @return [Array<ChunkyPNG::Chunk::Generic>]
    attr_accessor :other_chunks

    # The chunk containing the image's palette.
    # @return [ChunkyPNG::Chunk::Palette]
    attr_accessor :palette_chunk

    # The chunk containing the transparency information of the palette.
    # @return [ChunkyPNG::Chunk::Transparency]
    attr_accessor :transparency_chunk

    # The chunk containing the physical dimensions of the PNG's pixels.
    # @return [ChunkyPNG::Chunk::Physical]
    attr_accessor :physical_chunk

    # The chunks that together compose the images pixel data.
    # @return [Array<ChunkyPNG::Chunk::ImageData>]
    attr_accessor :data_chunks

    # The empty chunk that signals the end of this datastream
    # @return [ChunkyPNG::Chunk::Header]
    attr_accessor :end_chunk

    # Initializes a new Datastream instance.
    def initialize
      @other_chunks = []
      @data_chunks  = []
    end

    ##############################################################################
    # LOADING DATASTREAMS
    ##############################################################################

    class << self

      # Reads a PNG datastream from a string.
      # @param [String] str The PNG encoded string to load from.
      # @return [ChunkyPNG::Datastream] The loaded datastream instance.
      def from_blob(str)
        from_io(StringIO.new(str))
      end

      alias :from_string :from_blob

      # Reads a PNG datastream from a file.
      # @param [String] filename The path of the file to load from.
      # @return [ChunkyPNG::Datastream] The loaded datastream instance.
      def from_file(filename)
        ds = nil
        File.open(filename, 'rb') { |f| ds = from_io(f) }
        ds
      end

      # Reads a PNG datastream from an input stream
      # @param [IO] io The stream to read from.
      # @return [ChunkyPNG::Datastream] The loaded datastream instance.
      def from_io(io)
        verify_signature!(io)

        ds = self.new
        while ds.end_chunk.nil?
          chunk = ChunkyPNG::Chunk.read(io)
          case chunk
            when ChunkyPNG::Chunk::Header;       ds.header_chunk = chunk
            when ChunkyPNG::Chunk::Palette;      ds.palette_chunk = chunk
            when ChunkyPNG::Chunk::Transparency; ds.transparency_chunk = chunk
            when ChunkyPNG::Chunk::ImageData;    ds.data_chunks << chunk
            when ChunkyPNG::Chunk::Physical;     ds.physical_chunk = chunk
            when ChunkyPNG::Chunk::End;          ds.end_chunk = chunk
            else ds.other_chunks << chunk
          end
        end
        return ds
      end

      # Verifies that the current stream is a PNG datastream by checking its signature.
      #
      # This method reads the PNG signature from the stream, setting the current position
      # of the stream directly after the signature, where the IHDR chunk should begin.
      #
      # @param [IO] io The stream to read the PNG signature from.
      # @raise [RuntimeError] An exception is raised if the PNG signature is not found at
      #    the beginning of the stream.
      def verify_signature!(io)
        signature = io.read(ChunkyPNG::Datastream::SIGNATURE.length)
        unless ChunkyPNG.force_binary(signature) == ChunkyPNG::Datastream::SIGNATURE
          raise ChunkyPNG::SignatureMismatch, "PNG signature not found, found #{signature.inspect} instead of #{ChunkyPNG::Datastream::SIGNATURE.inspect}!"
        end
      end
    end

    ##################################################################################
    # CHUNKS
    ##################################################################################

    # Enumerates the chunks in this datastream.
    #
    # This will iterate over the chunks using the order in which the chunks
    # should appear in the PNG file.
    #
    # @yield [chunk] Yields the chunks in this datastream, one by one in the correct order.
    # @yieldparam [ChunkyPNG::Chunk::Base] chunk A chunk in this datastream.
    # @see ChunkyPNG::Datastream#chunks
    def each_chunk
      yield(header_chunk)
      other_chunks.each { |chunk| yield(chunk) }
      yield(palette_chunk)      if palette_chunk
      yield(transparency_chunk) if transparency_chunk
      yield(physical_chunk)     if physical_chunk
      data_chunks.each  { |chunk| yield(chunk) }
      yield(end_chunk)
    end

    # Returns an enumerator instance for this datastream's chunks.
    # @return [Enumerable::Enumerator] An enumerator for the :each_chunk method.
    # @see ChunkyPNG::Datastream#each_chunk
    def chunks
      enum_for(:each_chunk)
    end

    # Returns all the textual metadata key/value pairs as hash.
    # @return [Hash] A hash containing metadata fields and their values.
    def metadata
      metadata = {}
      other_chunks.select do |chunk|
        metadata[chunk.keyword] = chunk.value if chunk.respond_to?(:keyword) && chunk.respond_to?(:value)
      end
      metadata
    end

    # Returns the uncompressed image data, combined from all the IDAT chunks
    # @return [String] The uncompressed image data for this datastream
    def imagedata
      ChunkyPNG::Chunk::ImageData.combine_chunks(data_chunks)
    end

    ##################################################################################
    # WRITING DATASTREAMS
    ##################################################################################

    # Returns an empty stream using binary encoding that can be used as stream to encode to.
    # @return [String] An empty, binary string.
    def self.empty_bytearray
      ChunkyPNG::EMPTY_BYTEARRAY.dup
    end

    # Writes the datastream to the given output stream.
    # @param [IO] io The output stream to write to.
    def write(io)
      io << SIGNATURE
      each_chunk { |c| c.write(io) }
    end

    # Saves this datastream as a PNG file.
    # @param [String] filename The filename to use.
    def save(filename)
      File.open(filename, 'wb') { |f| write(f) }
    end

    # Encodes this datastream into a string.
    # @return [String] The encoded PNG datastream.
    def to_blob
      str = StringIO.new
      str.set_encoding('ASCII-8BIT')
      write(str)
      return str.string
    end

    alias :to_string :to_blob
    alias :to_s :to_blob
  end
end
