module Fog
  module Compute
    class OpenStack
      class Real
        def update_aggregate(uuid, options = {})
          vanilla_options = [:name, :availability_zone]

          data = {'aggregate' => {}}
          vanilla_options.select { |o| options[o] }.each do |key|
            data['aggregate'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'PUT',
            :path    => "os-aggregates/#{uuid}"
          )
        end
      end

      class Mock
        def update_aggregate(_uuid, _options = {})
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
