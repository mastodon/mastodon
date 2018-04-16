module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          ##
          # Destroy an EC2 credential for a user.  Requires administrator
          # credentials.
          #
          # ==== Parameters
          # * user_id<~String>: The id of the user to delete the credential
          #   for
          # * access<~String>: The access key of the credential to destroy
          #
          # ==== Returns
          # * response<~Excon::Response>:
          #   * body<~String>:  Empty string

          def delete_ec2_credential(user_id, access)
            request(
              :expects => [200, 204],
              :method  => 'DELETE',
              :path    => "users/#{user_id}/credentials/OS-EC2/#{access}"
            )
          end
        end

        class Mock
          def delete_ec2_credential(user_id, access)
            raise Fog::Identity::OpenStack::NotFound unless data[:ec2_credentials][user_id][access]

            data[:ec2_credentials][user_id].delete access

            response = Excon::Response.new
            response.status = 204
            response
          rescue
          end
        end
      end # class V2
    end
  end
end
