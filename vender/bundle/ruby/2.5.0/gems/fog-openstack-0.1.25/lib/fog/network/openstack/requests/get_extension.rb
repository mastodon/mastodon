module Fog
  module Network
    class OpenStack
      class Real
        def get_extension(name)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "extensions/#{name}"
          )
        end
      end

      class Mock
        def get_extension(name)
          response = Excon::Response.new
          if data = self.data[:extensions][name]
            response.status = 200
            response.body = {'extension' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
