module Aws
  module S3
    module Encryption
      # @api private
      class IODecrypter

        # @param [OpenSSL::Cipher] cipher
        # @param [IO#write] io An IO-like object that responds to `#write`.
        def initialize(cipher, io)
          @cipher = cipher.clone
          @io = io
        end

        # @return [#write]
        attr_reader :io

        def write(chunk)
          # decrypt and write
          @io.write(@cipher.update(chunk))
        end

        def finalize
          @io.write(@cipher.final)
        end

      end
    end
  end
end
