module Fog
  module Network
    class OpenStack
      class Real
        def list_lb_members(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lb/members',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lb_members(_filters = {})
          Excon::Response.new(
            :body   => {'members' => data[:lb_members].values},
            :status => 200
          )
        end
      end
    end
  end
end
