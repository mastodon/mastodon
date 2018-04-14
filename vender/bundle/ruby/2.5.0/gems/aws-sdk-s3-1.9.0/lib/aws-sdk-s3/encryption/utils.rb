require 'openssl'

module Aws
  module S3
    module Encryption
      # @api private
      module Utils

        UNSAFE_MSG = "unsafe encryption, data is longer than key length"

        class << self

          def encrypt(key, data)
            case key
            when OpenSSL::PKey::RSA # asymmetric encryption
              warn(UNSAFE_MSG) if key.public_key.n.num_bits < cipher_size(data)
              key.public_encrypt(data)
            when String # symmetric encryption
              warn(UNSAFE_MSG) if cipher_size(key) < cipher_size(data)
              cipher = aes_encryption_cipher(:ECB, key)
              cipher.update(data) + cipher.final
            end
          end

          def decrypt(key, data)
            begin
              case key
              when OpenSSL::PKey::RSA # asymmetric decryption
                key.private_decrypt(data)
              when String # symmetric Decryption
                cipher = aes_cipher(:decrypt, :ECB, key, nil)
                cipher.update(data) + cipher.final
              end
            rescue OpenSSL::Cipher::CipherError
              msg = 'decryption failed, possible incorrect key'
              raise Errors::DecryptionError, msg
            end
          end

          # @param [String] block_mode "CBC" or "ECB"
          # @param [OpenSSL::PKey::RSA, String, nil] key
          # @param [String, nil] iv The initialization vector
          def aes_encryption_cipher(block_mode, key = nil, iv = nil)
            aes_cipher(:encrypt, block_mode, key, iv)
          end

          # @param [String] block_mode "CBC" or "ECB"
          # @param [OpenSSL::PKey::RSA, String, nil] key
          # @param [String, nil] iv The initialization vector
          def aes_decryption_cipher(block_mode, key = nil, iv = nil)
            aes_cipher(:decrypt, block_mode, key, iv)
          end

          # @param [String] mode "encrypt" or "decrypt"
          # @param [String] block_mode "CBC" or "ECB"
          # @param [OpenSSL::PKey::RSA, String, nil] key
          # @param [String, nil] iv The initialization vector
          def aes_cipher(mode, block_mode, key, iv)
            cipher = key ?
              OpenSSL::Cipher.new("aes-#{cipher_size(key)}-#{block_mode.downcase}") :
              OpenSSL::Cipher.new("aes-256-#{block_mode.downcase}")
            cipher.send(mode) # encrypt or decrypt
            cipher.key = key if key
            cipher.iv = iv if iv
            cipher
          end

          # @param [String] key
          # @return [Integer]
          # @raise ArgumentError
          def cipher_size(key)
            key.bytesize * 8
          end

        end
      end
    end
  end
end
