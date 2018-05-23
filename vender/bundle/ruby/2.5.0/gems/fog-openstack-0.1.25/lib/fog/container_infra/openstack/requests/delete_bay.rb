module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def delete_bay(uuid_or_name)
          request(
            :expects => [204],
            :method  => 'DELETE',
            :path    => "bays/#{uuid_or_name}"
          )
        end
      end

      class Mock
        def delete_bay(_uuid_or_name)
          response = Excon::Response.new
          response.status = 204
          response.body = {}
          response
        end
      end
    end
  end
end
