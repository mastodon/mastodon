module Aws
  module Plugins
    # @api private
    class SignatureV2 < Seahorse::Client::Plugin

      option(:v2_signer) do |cfg|
        Aws::Sigv2::Signer.new(credentials_provider: cfg.credentials)
      end

      def add_handlers(handlers, _)
        handlers.add(Handler, step: :sign)
      end

      class Handler < Seahorse::Client::Handler

        def call(context)
          apply_signature(
            context.http_request,
            context.config.v2_signer
          )
          @handler.call(context)
        end

        private

        def apply_signature(req, signer)

          param_list = req.body.param_list
          param_list.delete('Timestamp') # in case of re-signing

          signature = signer.sign_request(
            http_method: req.http_method,
            url: req.endpoint,
            params: param_list.inject({}) do |hash, param|
              hash[param.name] = param.value
              hash
            end
          )

          # apply signature
          signature.each_pair do |param_name, param_value|
            param_list.set(param_name, param_value)
          end

          req.body = param_list.to_io

        end
      end
    end
  end
end
