# Basic requirements from standard library
require 'set'
require 'zlib'
require 'stringio'
require 'enumerator'

# ChunkyPNG - the pure ruby library to access PNG files.
#
# The ChunkyPNG module defines some constants that are used in the
# PNG specification, specifies some exception classes, and serves as
# a namespace for all the other modules and classes in this library.
#
# {ChunkyPNG::Image}::      class to represent PNG images, including metadata.
# {ChunkyPNG::Canvas}::     class to represent the image's canvas.
# {ChunkyPNG::Color}::      module to work with color values.
# {ChunkyPNG::Palette}::    represents the palette of colors used on a {ChunkyPNG::Canvas}.
# {ChunkyPNG::Datastream}:: represents the internal structure of a PNG {ChunkyPNG::Image}.
# {ChunkyPNG::Color}::      represents one chunk of data within a {ChunkyPNG::Datastream}.
# {ChunkyPNG::Point}::      geometry helper class representing a 2-dimensional point.
# {ChunkyPNG::Dimension}::  geometry helper class representing a dimension (i.e. width x height).
# {ChunkyPNG::Vector}::     geometry helper class representing a series of points.
#
# @author Willem van Bergen
module ChunkyPNG

  ###################################################
  # PNG international standard defined constants
  ###################################################

  # Indicates that the PNG image uses grayscale colors, i.e. only a
  # single teint channel.
  # @private
  COLOR_GRAYSCALE       = 0

  # Indicates that the PNG image uses true color, composed of a red
  # green and blue channel.
  # @private
  COLOR_TRUECOLOR       = 2

  # Indicates that the PNG image uses indexed colors, where the values
  # point to colors defined on a palette.
  # @private
  COLOR_INDEXED         = 3

  # Indicates that the PNG image uses grayscale colors with opacity, i.e.
  # a teint channel with an alpha channel.
  # @private
  COLOR_GRAYSCALE_ALPHA = 4

  # Indicates that the PNG image uses true color with opacity, composed of
  # a red, green and blue channel, and an alpha value.
  # @private
  COLOR_TRUECOLOR_ALPHA = 6

  # Indicates that the PNG specification's default compression
  # method is used (Zlib/Deflate)
  # @private
  COMPRESSION_DEFAULT   = 0

  # Indicates that the PNG chunk content is not compressed
  # flag used in iTXt chunk
  # @private
  UNCOMPRESSED_CONTENT  = 0

  # Indicates that the PNG chunk content is compressed
  # flag used in iTXt chunk
  # @private
  COMPRESSED_CONTENT    = 1

  # Indicates that the image does not use interlacing.
  # @private
  INTERLACING_NONE      = 0

  # Indicates that the image uses Adam7 interlacing.
  # @private
  INTERLACING_ADAM7     = 1

  ### Filter method constants

  # Indicates that the PNG specification's default filtering are
  # being used in the image.
  # @private
  FILTERING_DEFAULT     = 0

  # Indicates that no filtering is used for the scanline.
  # @private
  FILTER_NONE           = 0

  # Indicates that SUB filtering is used for the scanline.
  # @private
  FILTER_SUB            = 1

  # Indicates that UP filtering is used for the scanline.
  # @private
  FILTER_UP             = 2

  # Indicates that AVERAGE filtering is used for the scanline.
  # @private
  FILTER_AVERAGE        = 3

  # Indicates that PAETH filtering is used for the scanline.
  # @private
  FILTER_PAETH          = 4

  ###################################################
  # ChunkyPNG exception classes
  ###################################################

  # Default exception class for ChunkyPNG
  class Exception < ::StandardError
  end

  # Exception that is raised for an unsupported PNG image.
  class NotSupported < ChunkyPNG::Exception
  end

  # Exception that is raised if the PNG signature is not encountered at the
  # beginning of the file.
  class SignatureMismatch < ChunkyPNG::Exception
  end

  # Exception that is raised if the CRC check for a block fails
  class CRCMismatch < ChunkyPNG::Exception
  end

  # Exception that is raised if an tTXt chunk does not contain valid UTF-8 data.
  class InvalidUTF8 < ChunkyPNG::Exception
  end

  # Exception that is raised if an expectation fails.
  class ExpectationFailed < ChunkyPNG::Exception
  end

  # Exception that is raised if an expectation fails.
  class OutOfBounds < ChunkyPNG::ExpectationFailed
  end

  # Exception that is raised when requesting the DPI of a PNG that doesn't
  # specify the units of its physical pixel dimensions.
  class UnitsUnknown < ChunkyPNG::Exception
  end

  def self.force_binary(str)
    str.respond_to?(:force_encoding) ? str.force_encoding('BINARY') : str
  end

  # Empty byte array. This basically is an empty string, but with the encoding
  # set correctly to ASCII-8BIT (binary) in Ruby 1.9.
  # @return [String] An empty string, with encoding set to binary in Ruby 1.9
  # @private
  EMPTY_BYTEARRAY = force_binary(String.new).freeze

  # Null-byte, with the encoding set correctly to ASCII-8BIT (binary) in Ruby 1.9.
  # @return [String] A binary string, consisting of one NULL-byte.
  # @private
  EXTRA_BYTE = force_binary(String.new("\0")).freeze
end

require 'chunky_png/version'

# Ruby 1.8 / 1.9 compatibility
require 'chunky_png/compatibility'

# PNG file structure
require 'chunky_png/datastream'
require 'chunky_png/chunk'

# Colors
require 'chunky_png/palette'
require 'chunky_png/color'

# Geometry
require 'chunky_png/point'
require 'chunky_png/vector'
require 'chunky_png/dimension'

# Canvas / Image classes
require 'chunky_png/canvas'
require 'chunky_png/image'
