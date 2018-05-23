module ChunkyPNG
  # A PNG datastream consists of multiple chunks. This module, and the classes
  # contained within, help with handling these chunks. It supports both reading
  # and writing chunks.
  #
  # All chunk types are instances of the {ChunkyPNG::Chunk::Base} class. For
  # some chunk types a specialized class is available, e.g. the IHDR chunk is
  # represented by the {ChunkyPNG::Chunk::Header} class. These specialized
  # classes help accessing the content of the chunk. All other chunks are
  # represented by the {ChunkyPNG::Chunk::Generic} class.
  #
  # @see ChunkyPNG::Datastream
  module Chunk
    # Reads a chunk from an IO stream.
    #
    # @param io [IO, #read] The IO stream to read from.
    # @return [ChunkyPNG::Chung::Base] The loaded chunk instance.
    def self.read(io)
      length, type = read_bytes(io, 8).unpack('Na4')

      content = read_bytes(io, length)
      crc     = read_bytes(io, 4).unpack('N').first
      verify_crc!(type, content, crc)

      CHUNK_TYPES.fetch(type, Generic).read(type, content)
    end

    # Reads an exact number of bytes from an IO stream.
    # @param io [IO, #read] The IO stream to read from.
    # @param length [Integer] The IO exact number of bytes to read.
    # @return [String] A binary string of exactly length bytes.
    # @raise [ChunkyPNG::ExpectationFailed] If not exactly length
    #   bytes could be read from the IO stream.
    def self.read_bytes(io, length)
      data = io.read(length)
      raise ExpectationFailed, "Couldn't read #{length} bytes from IO stream." if data.nil? || data.bytesize != length
      data
    end

    # Verifies the CRC of a chunk.
    # @param type [String] The chunk's type.
    # @param content [String] The chunk's content.
    # @param found_crc [Integer] The chunk's found CRC value.
    # @raise [ChunkyPNG::CRCMismatch] An exception is raised if
    #   the found CRC value is not equal to the expected CRC value.
    def self.verify_crc!(type, content, found_crc)
      expected_crc = Zlib.crc32(content, Zlib.crc32(type))
      raise ChunkyPNG::CRCMismatch, "Chuck CRC mismatch!" if found_crc != expected_crc
    end

    # The base chunk class is the superclass for every chunk type. It contains
    # methods to write the chunk to an output stream.
    #
    # A subclass should implement the +content+ method, which gets called when
    # the chunk gets written to a PNG datastream
    #
    # @abstract
    class Base
      # The four-character type indicator for the chunk. This field is used to
      # find the correct class for a chunk when it is loaded from a PNG stream.
      # @return [String]
      attr_accessor :type

      # Initializes the chunk instance.
      # @param type [String] The four character chunk type indicator.
      # @param attributes [Hash] A hash of attributes to set on this chunk.
      def initialize(type, attributes = {})
        self.type = type
        attributes.each { |k, v| send("#{k}=", v) }
      end

      # Writes the chunk to the IO stream, using the provided content.
      # The checksum will be calculated and appended to the stream.
      # @param io [IO] The IO stream to write to.
      # @param content [String] The content for this chunk.
      def write_with_crc(io, content)
        io << [content.length].pack('N') << type << content
        io << [Zlib.crc32(content, Zlib.crc32(type))].pack('N')
      end

      # Writes the chunk to the IO stream.
      #
      # It will call the +content+ method to get the content for this chunk,
      # and will calculate and append the checksum automatically.
      # @param io [IO] The IO stream to write to.
      def write(io)
        write_with_crc(io, content || '')
      end
    end

    # The Generic chunk type will read the content from the chunk as it,
    # and will write it back as it was read.
    class Generic < Base
      # The attribute to store the content from the chunk, which gets
      # written by the +write+ method.
      attr_accessor :content

      def initialize(type, content = '')
        super(type, :content => content)
      end

      # Creates an instance, given the chunk's type and content.
      # @param type [String] The four character chunk type indicator.
      # @param content [String] The content read from the chunk.
      # @return [ChunkyPNG::Chunk::Generic] The new chunk instance.
      def self.read(type, content)
        new(type, content)
      end
    end

    # The header (IHDR) chunk is the first chunk of every PNG image, and
    # contains information about the image: i.e. its width, height, color
    # depth, color mode, compression method, filtering method and interlace
    # method.
    #
    # ChunkyPNG supports all values for these variables that are defined in the
    # PNG spec, except for color depth: Only 8-bit depth images are supported.
    # Note that it is still possible to access the chunk for such an image, but
    # ChunkyPNG will raise an exception if you try to access the pixel data.
    class Header < Base
      attr_accessor :width, :height, :depth, :color, :compression, :filtering,
                    :interlace

      def initialize(attrs = {})
        super('IHDR', attrs)
        @depth       ||= 8
        @color       ||= ChunkyPNG::COLOR_TRUECOLOR
        @compression ||= ChunkyPNG::COMPRESSION_DEFAULT
        @filtering   ||= ChunkyPNG::FILTERING_DEFAULT
        @interlace   ||= ChunkyPNG::INTERLACING_NONE
      end

      # Reads the 13 bytes of content from the header chunk to set the image
      # attributes.
      # @param type [String] The four character chunk type indicator (= "IHDR").
      # @param content [String] The 13 bytes of content read from the chunk.
      # @return [ChunkyPNG::Chunk::End] The new Header chunk instance with the
      #   variables set to the values according to the content.
      def self.read(type, content)
        fields = content.unpack('NNC5')
        new(:width => fields[0],
            :height => fields[1],
            :depth => fields[2],
            :color => fields[3],
            :compression => fields[4],
            :filtering => fields[5],
            :interlace => fields[6])
      end

      # Returns the content for this chunk when it gets written to a file, by
      # packing the image information variables into the correct format.
      # @return [String] The 13-byte content for the header chunk.
      def content
        [width, height, depth, color, compression, filtering, interlace].
          pack('NNC5')
      end
    end

    # The End (IEND) chunk indicates the last chunk of a PNG stream. It does
    # not contain any data.
    class End < Base

      def initialize
        super('IEND')
      end

      # Reads the END chunk. It will check if the content is empty.
      # @param type [String] The four character chunk type indicator (=
      #   "IEND").
      # @param content [String] The content read from the chunk. Should be
      #   empty.
      # @return [ChunkyPNG::Chunk::End] The new End chunk instance.
      # @raise [ChunkyPNG::ExpectationFailed] Raises an exception if the content was not empty.
      def self.read(type, content)
        raise ExpectationFailed, 'The IEND chunk should be empty!' if content.bytesize > 0
        self.new
      end

      # Returns an empty string, because this chunk should always be empty.
      # @return [""] An empty string.
      def content
        ChunkyPNG::Datastream.empty_bytearray
      end
    end

    # The Palette (PLTE) chunk contains the image's palette, i.e. the
    # 8-bit RGB colors this image is using.
    #
    # @see ChunkyPNG::Chunk::Transparency
    # @see ChunkyPNG::Palette
    class Palette < Generic
    end

    # A transparency (tRNS) chunk defines the transparency for an image.
    #
    # * For indexed images, it contains the alpha channel for the colors
    #   defined in the Palette (PLTE) chunk.
    # * For grayscale images, it contains the grayscale teint that should be
    #   considered fully transparent.
    # * For truecolor images, it contains the color that should be considered
    #   fully transparent.
    #
    # Images having a color mode that already includes an alpha channel, this
    # chunk should not be included.
    #
    # @see ChunkyPNG::Chunk::Palette
    # @see ChunkyPNG::Palette
    class Transparency < Generic
      # Returns the alpha channel for the palette of an indexed image.
      #
      # This method should only be used for images having color mode
      # ChunkyPNG::COLOR_INDEXED (3).
      #
      # @return [Array<Integer>] Returns an array of alpha channel values
      #   [0-255].
      def palette_alpha_channel
        content.unpack('C*')
      end

      # Returns the truecolor entry to be replaced by transparent pixels,
      #
      # This method should only be used for images having color mode
      # ChunkyPNG::COLOR_TRUECOLOR (2).
      #
      # @return [Integer] The color to replace with fully transparent pixels.
      def truecolor_entry(bit_depth)
        values = content.unpack('nnn').map do |c|
          ChunkyPNG::Canvas.send(:"decode_png_resample_#{bit_depth}bit_value", c)
        end
        ChunkyPNG::Color.rgb(*values)
      end

      # Returns the grayscale entry to be replaced by transparent pixels.
      #
      # This method should only be used for images having color mode
      # ChunkyPNG::COLOR_GRAYSCALE (0).
      #
      # @return [Integer] The (grayscale) color to replace with fully
      #   transparent pixels.
      def grayscale_entry(bit_depth)
        value = ChunkyPNG::Canvas.send(:"decode_png_resample_#{bit_depth}bit_value", content.unpack('n')[0])
        ChunkyPNG::Color.grayscale(value)
      end
    end

    class ImageData < Generic
      def self.combine_chunks(data_chunks)
        zstream = Zlib::Inflate.new
        data_chunks.each { |c| zstream << c.content }
        inflated = zstream.finish
        zstream.close
        inflated
      end

      def self.split_in_chunks(data, level = Zlib::DEFAULT_COMPRESSION, chunk_size = 2147483647)
        streamdata = Zlib::Deflate.deflate(data, level)
        # TODO: Split long streamdata over multiple chunks
        [ ChunkyPNG::Chunk::ImageData.new('IDAT', streamdata) ]
      end
    end

    # The Text (tEXt) chunk contains keyword/value metadata about the PNG
    # stream.  In this chunk, the value is stored uncompressed.
    #
    # The tEXt chunk only supports Latin-1 encoded textual data. If you need
    # UTF-8 support, check out the InternationalText chunk type.
    #
    # @see ChunkyPNG::Chunk::CompressedText
    # @see ChunkyPNG::Chunk::InternationalText
    class Text < Base
      attr_accessor :keyword, :value

      def initialize(keyword, value)
        super('tEXt')
        @keyword, @value = keyword, value
      end

      def self.read(type, content)
        keyword, value = content.unpack('Z*a*')
        new(keyword, value)
      end

      # Creates the content to write to the stream, by concatenating the
      # keyword with the value, joined by a null character.
      #
      # @return The content that should be written to the datastream.
      def content
        [keyword, value].pack('Z*a*')
      end
    end

    # The CompressedText (zTXt) chunk contains keyword/value metadata about the
    # PNG stream. In this chunk, the value is compressed using Deflate
    # compression.
    #
    # @see ChunkyPNG::Chunk::CompressedText
    # @see ChunkyPNG::Chunk::InternationalText
    class CompressedText < Base
      attr_accessor :keyword, :value

      def initialize(keyword, value)
        super('zTXt')
        @keyword, @value = keyword, value
      end

      def self.read(type, content)
        keyword, compression, value = content.unpack('Z*Ca*')
        raise ChunkyPNG::NotSupported, "Compression method #{compression.inspect} not supported!" unless compression == ChunkyPNG::COMPRESSION_DEFAULT
        new(keyword, Zlib::Inflate.inflate(value))
      end

      # Creates the content to write to the stream, by concatenating the
      # keyword with the deflated value, joined by a null character.
      #
      # @return The content that should be written to the datastream.
      def content
        [keyword, ChunkyPNG::COMPRESSION_DEFAULT, Zlib::Deflate.deflate(value)].
          pack('Z*Ca*')
      end
    end

    # The Physical (pHYs) chunk specifies the intended pixel size or aspect
    # ratio for display of the image.
    #
    # http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html#C.pHYs
    class Physical < Base
      attr_accessor :ppux, :ppuy, :unit

      def initialize(ppux, ppuy, unit = :unknown)
        raise ArgumentError, 'unit must be either :meters or :unknown' unless [:meters, :unknown].member?(unit)
        super('pHYs')
        @ppux, @ppuy, @unit = ppux, ppuy, unit
      end

      def dpix
        raise ChunkyPNG::UnitsUnknown, 'the PNG specifies its physical aspect ratio, but does not specify the units of its pixels\' physical dimensions' unless unit == :meters
        ppux * INCHES_PER_METER
      end

      def dpiy
        raise ChunkyPNG::UnitsUnknown, 'the PNG specifies its physical aspect ratio, but does not specify the units of its pixels\' physical dimensions' unless unit == :meters
        ppuy * INCHES_PER_METER
      end

      def self.read(type, content)
        ppux, ppuy, unit = content.unpack('NNC')
        unit = unit == 1 ? :meters : :unknown
        new(ppux, ppuy, unit)
      end

      # Assembles the content to write to the stream for this chunk.
      # @return [String] The binary content that should be written to the datastream.
      def content
        [ppux, ppuy, unit == :meters ? 1 : 0].pack('NNC')
      end

      INCHES_PER_METER = 0.0254
    end

    # The InternationalText (iTXt) chunk contains keyword/value metadata about the PNG
    # stream, translated to a given locale.
    #
    # The metadata in this chunk can be encoded using UTF-8 characters.
    # Moreover, it is possible to define the language of the metadata, and give
    # a translation of the keyword name. Finally, it supports bot compressed
    # and uncompressed values.
    #
    # http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html#C.iTXt
    #
    # @see ChunkyPNG::Chunk::Text
    # @see ChunkyPNG::Chunk::CompressedText
    class InternationalText < Base
      attr_accessor :keyword, :text, :language_tag, :translated_keyword, :compressed, :compression

      def initialize(keyword, text, language_tag = '', translated_keyword = '', compressed = ChunkyPNG::UNCOMPRESSED_CONTENT, compression = ChunkyPNG::COMPRESSION_DEFAULT)
        super('iTXt')
        @keyword = keyword
        @text = text
        @language_tag = language_tag
        @translated_keyword = translated_keyword
        @compressed = compressed
        @compression = compression
      end

      # Reads the tTXt chunk.
      # @param type [String] The four character chunk type indicator (= "iTXt").
      # @param content [String] The content read from the chunk.
      # @return [ChunkyPNG::Chunk::InternationalText] The new End chunk instance.
      # @raise [ChunkyPNG::InvalidUTF8] If the chunk contains data that is not UTF8-encoded text.
      # @raise [ChunkyPNG::NotSupported] If the chunk refers to an unsupported compression method.
      #  Currently uncompressed data and deflate are supported.
      def self.read(type, content)
        keyword, compressed, compression, language_tag, translated_keyword, text = content.unpack('Z*CCZ*Z*a*')
        raise ChunkyPNG::NotSupported, "Compression flag #{compressed.inspect} not supported!" unless compressed == ChunkyPNG::UNCOMPRESSED_CONTENT || compressed == ChunkyPNG::COMPRESSED_CONTENT
        raise ChunkyPNG::NotSupported, "Compression method #{compression.inspect} not supported!" unless compression == ChunkyPNG::COMPRESSION_DEFAULT

        text = Zlib::Inflate.inflate(text) if compressed == ChunkyPNG::COMPRESSED_CONTENT

        text.force_encoding('utf-8')
        raise ChunkyPNG::InvalidUTF8, "Invalid unicode encountered in iTXt chunk" unless text.valid_encoding?

        translated_keyword.force_encoding('utf-8')
        raise ChunkyPNG::InvalidUTF8, "Invalid unicode encountered in iTXt chunk" unless translated_keyword.valid_encoding?

        new(keyword, text, language_tag, translated_keyword, compressed, compression)
      end

      # Assembles the content to write to the stream for this chunk.
      # @return [String] The binary content that should be written to the datastream.
      def content
        text_field = text.encode('utf-8')
        text_field = (compressed == ChunkyPNG::COMPRESSED_CONTENT) ? Zlib::Deflate.deflate(text_field) : text_field

        [keyword, compressed, compression, language_tag, translated_keyword.encode('utf-8'), text_field].pack('Z*CCZ*Z*a*')
      end
    end

    # Maps chunk types to classes, based on the four byte chunk type indicator
    # at the beginning of a chunk.
    #
    # If a chunk type is not specified in this hash, the Generic chunk type
    # will be used.
    #
    # @see ChunkyPNG::Chunk.read
    CHUNK_TYPES = {
      'IHDR' => Header,
      'IEND' => End,
      'IDAT' => ImageData,
      'PLTE' => Palette,
      'tRNS' => Transparency,
      'tEXt' => Text,
      'zTXt' => CompressedText,
      'iTXt' => InternationalText,
      'pHYs' => Physical,
    }
  end
end
