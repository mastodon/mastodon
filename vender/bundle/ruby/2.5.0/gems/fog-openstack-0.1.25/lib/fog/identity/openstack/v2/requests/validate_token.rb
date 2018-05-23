module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def validate_token(token_id, tenant_id = nil)
            request(
              :expects => [200, 203],
              :method  => 'GET',
              :path    => "tokens/#{token_id}" + (tenant_id ? "?belongsTo=#{tenant_id}" : '')
            )
          end
        end

        class Mock
          def validate_token(token_id, tenant_id = nil)
          end
        end
      end
    end
  end
end
