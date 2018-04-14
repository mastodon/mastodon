module Fog
  module Volume
    class OpenStack
      module Real
        def list_snapshots(options = true, options_deprecated = {})
          if options.kind_of?(Hash)
            path  = 'snapshots'
            query = options
          else
            # Backwards compatibility layer, when 'detailed' boolean was sent as first param
            if options
              Fog::Logger.deprecation('Calling OpenStack[:volume].list_snapshots(true) is deprecated, use .list_snapshots_detailed instead')
            else
              Fog::Logger.deprecation('Calling OpenStack[:volume].list_snapshots(false) is deprecated, use .list_snapshots({}) instead')
            end
            path  = options ? 'snapshots/detail' : 'snapshots'
            query = options_deprecated
          end

          request(
            :expects => 200,
            :method  => 'GET',
            :path    => path,
            :query   => query
          )
        end
      end

      module Mock
        def list_snapshots(_detailed = true, _options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'snapshots' => [get_snapshot_details.body["snapshot"]]
          }
          response
        end
      end
    end
  end
end
