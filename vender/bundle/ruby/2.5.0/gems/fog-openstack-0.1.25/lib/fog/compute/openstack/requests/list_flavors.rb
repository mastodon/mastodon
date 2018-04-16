module Fog
  module Compute
    class OpenStack
      class Real
        def list_flavors(options = {})
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => 'flavors',
            :query   => options
          )
        end
      end

      class Mock
        def list_flavors(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'flavors' => [
              {'name' => '256 server', 'id' => '1', 'links' => ['https://itdoesntmatterwhatshere.heh']},
              {'name' => '512 server', 'id' => '2', 'links' => ['https://itdoesntmatterwhatshere.heh']},
              {'name' => '1GB server', 'id' => '3', 'links' => ['https://itdoesntmatterwhatshere.heh']},
              {'name' => '2GB server', 'id' => '4', 'links' => ['https://itdoesntmatterwhatshere.heh']},
              {'name' => '4GB server', 'id' => '5', 'links' => ['https://itdoesntmatterwhatshere.heh']},
              {'name' => '8GB server', 'id' => '6', 'links' => ['https://itdoesntmatterwhatshere.heh']},
              {'name' => '15.5GB server', 'id' => '7', 'links' => ['https://itdoesntmatterwhatshere.heh']}
            ]
          }
          response
        end
      end
    end
  end
end
