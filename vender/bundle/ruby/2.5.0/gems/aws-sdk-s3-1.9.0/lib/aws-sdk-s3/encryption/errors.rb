module Aws
  module S3
    module Encryption
      module Errors

        class DecryptionError < RuntimeError; end

        class EncryptionError < RuntimeError; end

      end
    end
  end
end
