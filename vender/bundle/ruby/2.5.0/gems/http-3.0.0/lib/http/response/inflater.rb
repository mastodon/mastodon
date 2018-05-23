# frozen_string_literal: true

require "zlib"

module HTTP
  class Response
    class Inflater
      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      def readpartial(*args)
        chunk = @connection.readpartial(*args)
        if chunk
          chunk = zstream.inflate(chunk)
        elsif !zstream.closed?
          zstream.finish
          zstream.close
        end
        chunk
      end

      private

      def zstream
        @zstream ||= Zlib::Inflate.new(32 + Zlib::MAX_WBITS)
      end
    end
  end
end
