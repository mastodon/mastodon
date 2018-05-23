module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          ##
          # Create an EC2 credential for a user in a tenant.  Requires
          # administrator credentials.
          #
          # ==== Parameters
          # * user_id<~String>: The id of the user to create an EC2 credential
          #   for
          # * tenant_id<~String>: The id of the tenant to create the credential
          #   in
          #
          # ==== Returns
          # * response<~Excon::Response>:
          #   * body<~Hash>:
          #     * 'credential'<~Hash>: Created EC2 credential
          #       * 'access'<~String>: The access key
          #       * 'secret'<~String>: The secret key
          #       * 'user_id'<~String>: The user id
          #       * 'tenant_id'<~String>: The tenant id

          def create_ec2_credential(user_id, tenant_id)
            data = {'tenant_id' => tenant_id}

            request(
              :body    => Fog::JSON.encode(data),
              :expects => [200, 202],
              :method  => 'POST',
              :path    => "users/#{user_id}/credentials/OS-EC2"
            )
          end
        end

        class Mock
          def create_ec2_credential(user_id, tenant_id)
            response = Excon::Response.new
            response.status = 200

            data = {
              'access'    => Fog::Mock.random_hex(32),
              'secret'    => Fog::Mock.random_hex(32),
              'tenant_id' => tenant_id,
              'user_id'   => user_id,
            }

            self.data[:ec2_credentials][user_id][data['access']] = data

            response.body = {'credential' => data}

            response
          end
        end
      end # class V2
    end
  end
end
