module Fog
  module Network
    class OpenStack
      class Real
        def list_lb_vips(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lb/vips',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lb_vips(_filters = {})
          Excon::Response.new(
            :body   => {'vips' => data[:lb_vips].values},
            :status => 200
          )
        end
      end
    end
  end
end
