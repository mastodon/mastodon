module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def list_tenants(options = nil, marker = nil)
            if options.kind_of?(Hash)
              params = options
            else
              Fog::Logger.deprecation('Calling OpenStack[:identity].list_tenants(limit, marker) is deprecated, use'\
                                      ' .list_ec2_credentials(:limit => value, :marker => value)')
              params = {}
              params['limit'] = options if options
              params['marker'] = marker if marker
            end

            request(
              :expects => [200, 204],
              :method  => 'GET',
              :path    => "tenants",
              :query   => params
            )
          end
        end # class Real

        class Mock
          def list_tenants(_options = nil, _marker = nil)
            Excon::Response.new(
              :body   => {
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
              },
              :status => [200, 204][rand(2)]
            )
          end # def list_tenants
        end # class Mock
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog
