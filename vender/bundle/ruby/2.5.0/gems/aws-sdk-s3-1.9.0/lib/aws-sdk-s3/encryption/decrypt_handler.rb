require 'base64'

module Aws
  module S3
    module Encryption
      # @api private
      class DecryptHandler < Seahorse::Client::Handler

        V1_ENVELOPE_KEYS = %w(
          x-amz-key
          x-amz-iv
          x-amz-matdesc
        )

        V2_ENVELOPE_KEYS = %w(
          x-amz-key-v2
          x-amz-iv
          x-amz-cek-alg
          x-amz-wrap-alg
          x-amz-matdesc
        )

        POSSIBLE_ENVELOPE_KEYS = (V1_ENVELOPE_KEYS + V2_ENVELOPE_KEYS).uniq

        POSSIBLE_ENCRYPTION_FORMATS = %w(
          AES/GCM/NoPadding
          AES/CBC/PKCS5Padding
          AES/CBC/PKCS7Padding
        )

        def call(context)
          attach_http_event_listeners(context)
          @handler.call(context)
        end

        private

        def attach_http_event_listeners(context)

          context.http_response.on_headers(200) do
            cipher = decryption_cipher(context)
            decrypter = body_contains_auth_tag?(context) ?
              authenticated_decrypter(context, cipher) :
              IODecrypter.new(cipher, context.http_response.body)
            context.http_response.body = decrypter
          end

          context.http_response.on_success(200) do
            decrypter = context.http_response.body
            decrypter.finalize
            decrypter.io.rewind if decrypter.io.respond_to?(:rewind)
            context.http_response.body = decrypter.io
          end

          context.http_response.on_error do
            if context.http_response.body.respond_to?(:io)
              context.http_response.body = context.http_response.body.io
            end
          end
        end

        def decryption_cipher(context)
          if envelope = get_encryption_envelope(context)
            context[:encryption][:cipher_provider].decryption_cipher(envelope)
          else
            raise Errors::DecryptionError, "unable to locate encryption envelope"
          end
        end

        def get_encryption_envelope(context)
          if context[:encryption][:envelope_location] == :metadata
            envelope_from_metadata(context) || envelope_from_instr_file(context)
          else
            envelope_from_instr_file(context) || envelope_from_metadata(context)
          end
        end

        def envelope_from_metadata(context)
          possible_envelope = {}
          POSSIBLE_ENVELOPE_KEYS.each do |suffix|
            if value = context.http_response.headers["x-amz-meta-#{suffix}"]
              possible_envelope[suffix] = value
            end
          end
          extract_envelope(possible_envelope)
        end

        def envelope_from_instr_file(context)
          suffix = context[:encryption][:instruction_file_suffix]
          possible_envelope = Json.load(context.client.get_object(
            bucket: context.params[:bucket],
            key: context.params[:key] + suffix
          ).body.read)
          extract_envelope(possible_envelope)
        rescue S3::Errors::ServiceError, Json::ParseError
          nil
        end

        def extract_envelope(hash)
          return v1_envelope(hash) if hash.key?('x-amz-key')
          return v2_envelope(hash) if hash.key?('x-amz-key-v2')
          if hash.keys.any? { |key| key.match(/^x-amz-key-(.+)$/) }
            msg = "unsupported envelope encryption version #{$1}"
            raise Errors::DecryptionError, msg
          else
            nil # no envelope found
          end
        end

        def v1_envelope(envelope)
          envelope
        end

        def v2_envelope(envelope)
          unless POSSIBLE_ENCRYPTION_FORMATS.include? envelope['x-amz-cek-alg']
            alg = envelope['x-amz-cek-alg'].inspect
            msg = "unsupported content encrypting key (cek) format: #{alg}"
            raise Errors::DecryptionError, msg
          end
          unless envelope['x-amz-wrap-alg'] == 'kms'
            # possible to support
            #   RSA/ECB/OAEPWithSHA-256AndMGF1Padding
            alg = envelope['x-amz-wrap-alg'].inspect
            msg = "unsupported key wrapping algorithm: #{alg}"
            raise Errors::DecryptionError, msg
          end
          unless V2_ENVELOPE_KEYS.sort == envelope.keys.sort
            msg = "incomplete v2 encryption envelope:\n"
            msg += "  expected: #{V2_ENVELOPE_KEYS.join(',')}\n"
            msg += "  got: #{envelope_keys.join(', ')}"
            raise Errors::DecryptionError, msg
          end
          envelope
        end

        # When the x-amz-meta-x-amz-tag-len header is present, it indicates
        # that the body of this object has a trailing auth tag. The header
        # indicates the length of that tag.
        #
        # This method fetches the tag from the end of the object by
        # making a GET Object w/range request. This auth tag is used
        # to initialize the cipher, and the decrypter truncates the
        # auth tag from the body when writing the final bytes.
        def authenticated_decrypter(context, cipher)
          if RUBY_VERSION.match(/1.9/)
            raise "authenticated decryption not supported by OpeenSSL in Ruby version ~> 1.9"
            raise Aws::Errors::NonSupportedRubyVersionError, msg
          end
          http_resp = context.http_response
          content_length = http_resp.headers['content-length'].to_i
          auth_tag_length = http_resp.headers['x-amz-meta-x-amz-tag-len']
          auth_tag_length = auth_tag_length.to_i / 8

          auth_tag = context.client.get_object(
            bucket: context.params[:bucket],
            key: context.params[:key],
            range: "bytes=-#{auth_tag_length}"
          ).body.read

          cipher.auth_tag = auth_tag
          cipher.auth_data = ''

          # The encrypted object contains both the cipher text
          # plus a trailing auth tag. This decrypter will the body
          # expect for the trailing auth tag.
          IOAuthDecrypter.new(
            io: http_resp.body,
            encrypted_content_length: content_length - auth_tag_length,
            cipher: cipher)
        end

        def body_contains_auth_tag?(context)
          context.http_response.headers['x-amz-meta-x-amz-tag-len']
        end

      end
    end
  end
end
