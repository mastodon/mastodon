module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        # For older versions v1.0-2.8 the export locations are responsed as an attribute of share (export_locations). 
        # For newer API versions (>= 2.9) it is available in separate APIs.
        # This method returns a list of the export locations.
        def list_share_export_locations(share_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "shares/#{share_id}/export_locations"
          )
        end
      end

      class Mock
        def list_share_export_locations(share_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {'export_locations' => data[:export_locations]}
          response
        end
      end
    end
  end
end
