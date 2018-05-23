module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def update_share(id, options = {})
          request(
            :body    => Fog::JSON.encode('share' => options),
            :expects => 200,
            :method  => 'PUT',
            :path    => "shares/#{id}"
          )
        end
      end

      class Mock
        def update_share(id, options = {})
          # stringify keys
          options = Hash[options.map { |k, v| [k.to_s, v] }]

          update_data(id, options)

          response = Excon::Response.new
          response.status = 200
          response.body = {'share' => data[:share_updated]}
          response
        end

        private

        def update_data(id, options)
          data[:share_updated]                  = data[:shares_detailed].first.merge(options)
          data[:share_updated]['id']            = id
          data[:share_updated]['status']        = "PENDING"
          data[:share_updated]['links']['self'] = "https://127.0.0.1:8786/v2/shares/#{id}"
        end
      end
    end
  end
end
