module OmniAuth
  module Strategies
    class CAS
      class LogoutRequest
        def initialize(strategy, request)
          @strategy, @request = strategy, request
        end

        def call(options = {})
          @options = options

          begin
            result = single_sign_out_callback.call(*logout_request)
          rescue StandardError => err
            return @strategy.fail! :logout_request, err
          else
            result = [200,{},'OK'] if result == true || result.nil?
          ensure
            return unless result

            # TODO: Why does ActionPack::Response return [status,headers,body]
            # when Rack::Response#new wants [body,status,headers]? Additionally,
            # why does Rack::Response differ in argument order from the usual
            # Rack-like [status,headers,body] array?
            return Rack::Response.new(result[2],result[0],result[1]).finish
          end
        end

      private

        def logout_request
          @logout_request ||= begin
            saml = Nokogiri.parse(@request.params['logoutRequest'])
            name_id = saml.xpath('//saml:NameID').text
            sess_idx = saml.xpath('//samlp:SessionIndex').text
            inject_params(name_id:name_id, session_index:sess_idx)
            @request
          end
        end

        def inject_params(new_params)
          rack_input = @request.env['rack.input'].read
          params = Rack::Utils.parse_query(rack_input, '&').merge new_params
          @request.env['rack.input'] = StringIO.new(Rack::Utils.build_query(params))
        rescue
          # A no-op intended to ensure that the ensure block is run
          raise
        ensure
          @request.env['rack.input'].rewind
        end

        def single_sign_out_callback
          @options[:on_single_sign_out]
        end
      end
    end
  end
end
