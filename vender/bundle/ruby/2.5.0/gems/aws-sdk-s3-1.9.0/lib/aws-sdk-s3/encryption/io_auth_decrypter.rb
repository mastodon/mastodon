module Aws
  module S3
    module Encryption
      # @api private
      class IOAuthDecrypter

        # @option options [required, IO#write] :io
        #   An IO-like object that responds to {#write}.
        # @option options [required, Integer] :encrypted_content_length
        #   The number of bytes to decrypt from the `:io` object.
        #   This should be the total size of `:io` minus the length of
        #   the cipher auth tag.
        # @option options [required, OpenSSL::Cipher] :cipher An initialized
        #   cipher that can be used to decrypt the bytes as they are
        #   written to the `:io` object. The cipher should already have
        #   its `#auth_tag` set.
        def initialize(options = {})
          @decrypter = IODecrypter.new(options[:cipher], options[:io])
          @max_bytes = options[:encrypted_content_length]
          @bytes_written = 0
        end

        def write(chunk)
          chunk = truncate_chunk(chunk)
          @bytes_written += chunk.bytesize
          @decrypter.write(chunk)
        end

        def finalize
          @decrypter.finalize
        end

        def io
          @decrypter.io
        end

        private

        def truncate_chunk(chunk)
          if chunk.bytesize + @bytes_written <= @max_bytes
            chunk
          else
            chunk[0..(@max_bytes - @bytes_written - 1)]
          end
        end

      end
    end
  end
end
