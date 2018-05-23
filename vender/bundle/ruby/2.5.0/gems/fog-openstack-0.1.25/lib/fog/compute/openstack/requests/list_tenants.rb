module Fog
  module Compute
    class OpenStack
      class Real
        def list_tenants
          response = @identity_connection.request(:expects => [200, 204],
                                                  :headers => {'Content-Type' => 'application/json',
                                                               'Accept'       => 'application/json',
                                                               'X-Auth-Token' => @auth_token},
                                                  :method  => 'GET',
                                                  :path    => '/v2.0/tenants')
          response.body = Fog::JSON.decode(response.body)
          response
        end
      end

      class Mock
        def list_tenants
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = {
            'tenants_links' => [],
            'tenants'       => [
              {'id'          => '1',
               'description' => 'Has access to everything',
               'enabled'     => true,
               'name'        => 'admin'},
              {'id'          => '2',
               'description' => 'Normal tenant',
               'enabled'     => true,
               'name'        => 'default'},
              {'id'          => '3',
               'description' => 'Disabled tenant',
               'enabled'     => false,
               'name'        => 'disabled'}
            ]
          }
          response
        end
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog
