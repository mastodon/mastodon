# frozen_string_literal: true

class GifReader
  attr_reader :animated

  EXTENSION_LABELS = [0xf9, 0x01, 0xff].freeze
  GIF_HEADERS      = %w(GIF87a GIF89a).freeze

  class GifReaderException < StandardError; end

  class UnknownImageType < GifReaderException; end

  class CannotParseImage < GifReaderException; end

  def self.animated?(path)
    new(path).animated
  rescue GifReaderException
    false
  end

  def initialize(path, max_frames = 2)
    @path      = path
    @nb_frames = 0

    File.open(path, 'rb') do |s|
      raise UnknownImageType unless GIF_HEADERS.include?(s.read(6))

      # Skip to "packed byte"
      s.seek(4, IO::SEEK_CUR)

      # "Packed byte" gives us the size of the GIF color table
      packed_byte, = s.read(1).unpack('C')

      # Skip background color and aspect ratio
      s.seek(2, IO::SEEK_CUR)

      if packed_byte & 0x80 != 0
        # GIF uses a global color table, skip it
        s.seek(3 * (1 << ((packed_byte & 0x07) + 1)), IO::SEEK_CUR)
      end

      # Now read data
      while @nb_frames < max_frames
        separator = s.read(1)

        case separator
        when ',' # Image block
          @nb_frames += 1

          # Skip to "packed byte"
          s.seek(8, IO::SEEK_CUR)
          packed_byte, = s.read(1).unpack('C')

          if packed_byte & 0x80 != 0
            # Image uses a local color table, skip it
            s.seek(3 * (1 << ((packed_byte & 0x07) + 1)), IO::SEEK_CUR)
          end

          # Skip lzw min code size
          raise InvalidValue unless s.read(1).unpack1('C') >= 2

          # Skip image data sub-blocks
          skip_sub_blocks!(s)
        when '!' # Extension block
          skip_extension_block!(s)
        when ';' # Trailer
          break
        else
          raise CannotParseImage
        end
      end
    end

    @animated = @nb_frames > 1
  end

  private

  def skip_extension_block!(file)
    if EXTENSION_LABELS.include?(file.read(1).unpack1('C'))
      block_size, = file.read(1).unpack('C')
      file.seek(block_size, IO::SEEK_CUR)
    end

    # Read until extension block end marker
    skip_sub_blocks!(file)
  end

  # Skip sub-blocks up until block end marker
  def skip_sub_blocks!(file)
    loop do
      size, = file.read(1).unpack('C')

      break if size.zero?

      file.seek(size, IO::SEEK_CUR)
    end
  end
end

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert animated GIFs to videos

  class GifTranscoder < Paperclip::Processor
    def make
      return File.open(@file.path) unless needs_convert?

      final_file = Paperclip::Transcoder.make(file, options, attachment)

      if options[:style] == :original
        attachment.instance.file_file_name    = File.basename(attachment.instance.file_file_name, '.*') + '.mp4'
        attachment.instance.file_content_type = 'video/mp4'
        attachment.instance.type              = MediaAttachment.types[:gifv]
      end

      final_file
    end

    private

    def needs_convert?
      GifReader.animated?(file.path)
    end
  end
end
