# frozen_string_literal: true
module Excon
  module Middleware
    class Decompress < Excon::Middleware::Base
      def request_call(datum)
        unless datum.has_key?(:response_block)
          key = datum[:headers].keys.detect {|k| k.to_s.casecmp('Accept-Encoding') == 0 } || 'Accept-Encoding'
          if datum[:headers][key].to_s.empty?
            datum[:headers][key] = 'deflate, gzip'
          end
        end
        @stack.request_call(datum)
      end

      def response_call(datum)
        body = datum[:response][:body]
        unless datum.has_key?(:response_block) || body.nil? || body.empty?
          if key = datum[:response][:headers].keys.detect {|k| k.casecmp('Content-Encoding') == 0 }
            encodings = Utils.split_header_value(datum[:response][:headers][key])
            if encoding = encodings.last
              if encoding.casecmp('deflate') == 0
                # assume inflate omits header
                datum[:response][:body] = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(body)
                encodings.pop
              elsif encoding.casecmp('gzip') == 0 || encoding.casecmp('x-gzip') == 0
                datum[:response][:body] = Zlib::GzipReader.new(StringIO.new(body)).read
                encodings.pop
              end
              datum[:response][:headers][key] = encodings.join(', ')
            end
          end
        end
        @stack.response_call(datum)
      end
    end
  end
end
