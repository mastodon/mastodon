module Fog
  module Compute
    class OpenStack
      class Real
        def create_aggregate(name, options = {})
          data = {
            'aggregate' => {
              'name' => name
            }
          }

          vanilla_options = [:availability_zone]

          vanilla_options.select { |o| options[o] }.each do |key|
            data['aggregate'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'POST',
            :path    => "os-aggregates"
          )
        end
      end

      class Mock
        def create_aggregate(_name, _options = {})
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "Content-Type"   => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response.body = {'aggregate' => data[:aggregates].first}
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
