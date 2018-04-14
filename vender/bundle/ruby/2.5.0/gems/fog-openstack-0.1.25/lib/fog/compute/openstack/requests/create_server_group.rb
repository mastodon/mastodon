module Fog
  module Compute
    class OpenStack
      class Real
        def create_server_group(name, policy)
          Fog::Compute::OpenStack::ServerGroup.validate_server_group_policy policy

          body = {'server_group' => {
            'name'     => name,
            'policies' => [policy]
          }}
          request(
            :body    => Fog::JSON.encode(body),
            :expects => 200,
            :method  => 'POST',
            :path    => 'os-server-groups'
          )
        end
      end

      class Mock
        def create_server_group(name, policy)
          Fog::Compute::OpenStack::ServerGroup.validate_server_group_policy policy
          id = SecureRandom.uuid
          data[:server_groups][id] = {:name => name, :policies => [policy], :members => []}
          get_server_group id
        end
      end
    end
  end
end
