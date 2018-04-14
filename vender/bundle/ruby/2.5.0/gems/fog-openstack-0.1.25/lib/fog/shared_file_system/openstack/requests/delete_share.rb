module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def delete_share(id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "shares/#{id}"
          )
        end
      end

      class Mock
        def delete_share(id)
          response = Excon::Response.new
          response.status = 202

          share                  = data[:share_updated] || data[:shares_detail].first.dup
          share['id']            = id
          share['links']['self'] = "https://127.0.0.1:8786/v2/shares/#{id}"

          response.body = {'share' => share}
          response
        end
      end
    end
  end
end
