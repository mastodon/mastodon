module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          ##
          # List EC2 credentials for a user.  Requires administrator
          # credentials.
          #
          # ==== Parameters hash
          # * :user_id<~String>: The id of the user to retrieve the credential
          #   for
          #
          # ==== Returns
          # * response<~Excon::Response>:
          #   * body<~Hash>:
          #     * 'credentials'<~Array>: The user's EC2 credentials
          #       * 'access'<~String>: The access key
          #       * 'secret'<~String>: The secret key
          #       * 'user_id'<~String>: The user id
          #       * 'tenant_id'<~String>: The tenant id

          def list_ec2_credentials(options = {})
            if options.kind_of?(Hash)
              user_id = options.delete(:user_id)
              query = options
            else
              Fog::Logger.deprecation('Calling OpenStack[:identity].list_ec2_credentials(user_id) is deprecated, use .list_ec2_credentials(:user_id => value)')
              user_id = options
              query = {}
            end

            request(
              :expects => [200, 202],
              :method  => 'GET',
              :path    => "users/#{user_id}/credentials/OS-EC2",
              :query   => query
            )
          end
        end

        class Mock
          def list_ec2_credentials(options = {})
            user_id = if options.kind_of?(Hash)
                        options.delete(:user_id)
                      else
                        options
                      end

            ec2_credentials = data[:ec2_credentials][user_id].values

            response = Excon::Response.new
            response.status = 200
            response.body = {'credentials' => ec2_credentials}
            response
          end
        end
      end # class V2
    end
  end
end
