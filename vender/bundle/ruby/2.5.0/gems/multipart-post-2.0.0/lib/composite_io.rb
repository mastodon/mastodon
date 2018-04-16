#--
# Copyright (c) 2007-2012 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

# Concatenate together multiple IO objects into a single, composite IO object
# for purposes of reading as a single stream.
#
# Usage:
#
#     crio = CompositeReadIO.new(StringIO.new('one'), StringIO.new('two'), StringIO.new('three'))
#     puts crio.read # => "onetwothree"
#
class CompositeReadIO
  # Create a new composite-read IO from the arguments, all of which should
  # respond to #read in a manner consistent with IO.
  def initialize(*ios)
    @ios = ios.flatten
    @index = 0
  end

  # Read from IOs in order until `length` bytes have been received.
  def read(length = nil, outbuf = nil)
    got_result = false
    outbuf = outbuf ? outbuf.replace("") : ""

    while io = current_io
      if result = io.read(length)
        got_result ||= !result.nil?
        result.force_encoding("BINARY") if result.respond_to?(:force_encoding)
        outbuf << result
        length -= result.length if length
        break if length == 0
      end
      advance_io
    end
    (!got_result && length) ? nil : outbuf
  end

  def rewind
    @ios.each { |io| io.rewind }
    @index = 0
  end

  private

  def current_io
    @ios[@index]
  end

  def advance_io
    @index += 1
  end
end

# Convenience methods for dealing with files and IO that are to be uploaded.
class UploadIO
  # Create an upload IO suitable for including in the params hash of a
  # Net::HTTP::Post::Multipart.
  #
  # Can take two forms. The first accepts a filename and content type, and
  # opens the file for reading (to be closed by finalizer).
  #
  # The second accepts an already-open IO, but also requires a third argument,
  # the filename from which it was opened (particularly useful/recommended if
  # uploading directly from a form in a framework, which often save the file to
  # an arbitrarily named RackMultipart file in /tmp).
  #
  # Usage:
  #
  #     UploadIO.new("file.txt", "text/plain")
  #     UploadIO.new(file_io, "text/plain", "file.txt")
  #
  attr_reader :content_type, :original_filename, :local_path, :io, :opts

  def initialize(filename_or_io, content_type, filename = nil, opts = {})
    io = filename_or_io
    local_path = ""
    if io.respond_to? :read
      # in Ruby 1.9.2, StringIOs no longer respond to path
      # (since they respond to :length, so we don't need their local path, see parts.rb:41)
      local_path = filename_or_io.respond_to?(:path) ? filename_or_io.path : "local.path"
    else
      io = File.open(filename_or_io)
      local_path = filename_or_io
    end
    filename ||= local_path

    @content_type = content_type
    @original_filename = File.basename(filename)
    @local_path = local_path
    @io = io
    @opts = opts
  end

  def self.convert!(io, content_type, original_filename, local_path)
    raise ArgumentError, "convert! has been removed. You must now wrap IOs using:\nUploadIO.new(filename_or_io, content_type, filename=nil)\nPlease update your code."
  end

  def method_missing(*args)
    @io.send(*args)
  end

  def respond_to?(meth, include_all = false)
    @io.respond_to?(meth, include_all) || super(meth, include_all)
  end
end
