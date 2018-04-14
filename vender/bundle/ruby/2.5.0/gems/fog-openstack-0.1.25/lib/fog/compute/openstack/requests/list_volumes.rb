module Fog
  module Compute
    class OpenStack
      class Real
        def list_volumes(options = true)
          if options.kind_of?(Hash)
            path = 'os-volumes'
            query = options
          else
            # Backwards compatibility layer, when 'detailed' boolean was sent as first param
            if options
              Fog::Logger.deprecation('Calling OpenStack[:compute].list_volumes(true) is deprecated, use .list_volumes_detail instead')
            else
              Fog::Logger.deprecation('Calling OpenStack[:compute].list_volumes(false) is deprecated, use .list_volumes({}) instead')
            end
            path = options ? 'os-volumes/detail' : 'os-volumes'
            query = {}
          end

          request(
            :expects => 200,
            :method  => 'GET',
            :path    => path,
            :query   => query
          )
        end
      end

      class Mock
        def list_volumes(_options = true)
          Excon::Response.new(
            :body   => {'volumes' => data[:volumes].values},
            :status => 200
          )
        end
      end
    end
  end
end
