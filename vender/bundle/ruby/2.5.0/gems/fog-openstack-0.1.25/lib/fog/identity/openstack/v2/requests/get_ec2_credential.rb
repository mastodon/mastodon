module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          ##
          # Retrieves an EC2 credential for a user.  Requires administrator
          # credentials.
          #
          # ==== Parameters
          # * user_id<~String>: The id of the user to retrieve the credential
          #   for
          # * access<~String>: The access key of the credential to retrieve
          #
          # ==== Returns
          # * response<~Excon::Response>:
          #   * body<~Hash>:
          #     * 'credential'<~Hash>: The EC2 credential
          #       * 'access'<~String>: The access key
          #       * 'secret'<~String>: The secret key
          #       * 'user_id'<~String>: The user id
          #       * 'tenant_id'<~String>: The tenant id

          def get_ec2_credential(user_id, access)
            request(
              :expects => [200, 202],
              :method  => 'GET',
              :path    => "users/#{user_id}/credentials/OS-EC2/#{access}"
            )
          rescue Excon::Errors::Unauthorized
            raise Fog::Identity::OpenStack::NotFound
          end
        end

        class Mock
          def get_ec2_credential(user_id, access)
            ec2_credential = data[:ec2_credentials][user_id][access]

            raise Fog::OpenStack::Identity::NotFound unless ec2_credential

            response = Excon::Response.new
            response.status = 200
            response.body = {'credential' => ec2_credential}
            response
          end
        end
      end # class V2
    end
  end
end
