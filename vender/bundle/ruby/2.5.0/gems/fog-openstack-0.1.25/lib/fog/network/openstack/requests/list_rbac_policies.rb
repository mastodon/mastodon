module Fog
  module Network
    class OpenStack
      class Real
        def list_rbac_policies(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'rbac-policies',
            :query   => filters
          )
        end
      end

      class Mock
        def list_rbac_policies(*)
          Excon::Response.new(
            :body   => {'rbac_policies' => data[:rbac_policies].values},
            :status => 200
          )
        end
      end
    end
  end
end
