module Fog
  module Compute
    class OpenStack
      class Real
        def list_servers(options = {})
          params = options.dup
          if params[:all_tenants]
            params['all_tenants'] = 'True'
            params.delete(:all_tenants)
          end

          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => 'servers',
            :query   => params
          )
        end
      end

      class Mock
        def list_servers(_options = {})
          response = Excon::Response.new
          data = list_servers_detail.body['servers']
          servers = []
          data.each do |server|
            servers << server.reject { |key, _value| !['id', 'name', 'links'].include?(key) }
          end
          response.status = [200, 203][rand(2)]
          response.body = {'servers' => servers}
          response
        end
      end
    end
  end
end
