require 'rack/auth/abstract/request'
require 'rack/auth/digest/params'
require 'rack/auth/digest/nonce'

module Rack
  module Auth
    module Digest
      class Request < Auth::AbstractRequest
        def method
          @env[RACK_METHODOVERRIDE_ORIGINAL_METHOD] || @env[REQUEST_METHOD]
        end

        def digest?
          "digest" == scheme
        end

        def correct_uri?
          request.fullpath == uri
        end

        def nonce
          @nonce ||= Nonce.parse(params['nonce'])
        end

        def params
          @params ||= Params.parse(parts.last)
        end

        def respond_to?(sym, *)
          super or params.has_key? sym.to_s
        end

        def method_missing(sym, *args)
          return super unless params.has_key?(key = sym.to_s)
          return params[key] if args.size == 0
          raise ArgumentError, "wrong number of arguments (#{args.size} for 0)"
        end
      end
    end
  end
end
