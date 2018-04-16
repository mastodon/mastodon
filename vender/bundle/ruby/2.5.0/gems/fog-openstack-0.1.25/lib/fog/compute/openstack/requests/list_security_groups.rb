module Fog
  module Compute
    class OpenStack
      class Real
        def list_security_groups(options = {})
          path = "os-security-groups"

          if options.kind_of?(Hash)
            server_id = options.delete(:server_id)
            query = options
          else
            # Backwards compatibility layer, only server_id was passed as first parameter previously
            Fog::Logger.deprecation('Calling OpenStack[:compute].list_security_groups(server_id) is deprecated, use .list_security_groups(:server_id => value) instead')
            server_id = options
            query = {}
          end

          if server_id
            path = "servers/#{server_id}/#{path}"
          end

          request(
            :expects => [200],
            :method  => 'GET',
            :path    => path,
            :query   => query
          )
        end
      end

      class Mock
        def list_security_groups(options = {})
          server_id = if options.kind_of?(Hash)
                        options.delete(:server_id)
                      else
                        options
                      end

          security_groups = data[:security_groups].values

          groups = if server_id
                     server_group_names =
                       Array(data[:server_security_group_map][server_id])

                     server_group_names.map do |name|
                       security_groups.find do |sg|
                         sg['name'] == name
                       end
                     end.compact
                   else
                     security_groups
                   end

          Excon::Response.new(
            :body    => {'security_groups' => groups},
            :headers => {
              "X-Compute-Request-Id" => "req-#{Fog::Mock.random_base64(36)}",
              "Content-Type"         => "application/json",
              "Date"                 => Date.new
            },
            :status  => 200
          )
        end
      end # mock
    end # openstack
  end # compute
end # fog
