module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def check_token(token_id, tenant_id = nil)
            request(
              :expects => [200, 203],
              :method  => 'HEAD',
              :path    => "tokens/#{token_id}" + (tenant_id ? "?belongsTo=#{tenant_id}" : '')
            )
          end
        end

        class Mock
          def check_token(token_id, tenant_id = nil)
          end
        end
      end
    end
  end
end
