begin
  require 'composite_io'
  require 'parts'
  require 'stringio'
rescue LoadError
  $stderr.puts "Install the multipart-post gem."
  raise
end

module Faraday
  # Similar but not compatible with ::CompositeReadIO provided by multipart-post.
  class CompositeReadIO
    def initialize(*parts)
      @parts = parts.flatten
      @ios = @parts.map { |part| part.to_io }
      @index = 0
    end

    def length
      @parts.inject(0) { |sum, part| sum + part.length }
    end

    def rewind
      @ios.each { |io| io.rewind }
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

    def close
      @ios.each { |io| io.close }
    end

    def ensure_open_and_readable
      # Rubinius compatibility
    end

    private

    def current_io
      @ios[@index]
    end

    def advance_io
      @index += 1
    end
  end

  UploadIO = ::UploadIO
  Parts = ::Parts
end
