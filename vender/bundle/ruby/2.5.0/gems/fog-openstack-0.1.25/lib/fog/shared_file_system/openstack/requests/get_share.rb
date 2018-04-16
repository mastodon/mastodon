module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def get_share(id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "shares/#{id}"
          )
        end
      end

      class Mock
        def get_share(id)
          response = Excon::Response.new
          response.status = 200
          share = data[:share_updated] || data[:shares_detail].first
          share['id'] = id
          response.body = share
          response
        end
      end
    end
  end
end
