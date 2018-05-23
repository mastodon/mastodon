module Fog
  module Network
    class OpenStack
      class Real
        def list_extensions(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'extensions',
            :query   => filters
          )
        end
      end

      class Mock
        def list_extensions(_filters = {})
          Excon::Response.new(
            :body   => {'extensions' => data[:extensions].values},
            :status => 200
          )
        end
      end
    end
  end
end
