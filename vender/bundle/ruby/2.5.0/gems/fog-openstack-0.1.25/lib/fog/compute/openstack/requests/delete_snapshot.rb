module Fog
  module Compute
    class OpenStack
      class Real
        def delete_snapshot(snapshot_id)
          request(
            :expects => 202,
            :method  => 'DELETE',
            :path    => "os-snapshots/#{snapshot_id}"
          )
        end
      end

      class Mock
        def delete_snapshot(snapshot_id)
          response = Excon::Response.new
          response.status = 204
          if list_snapshots_detail.body['snapshots'].find { |snap| snap['id'] == snapshot_id }
            data[:snapshots].delete(snapshot_id)
          else
            raise Fog::Compute::OpenStack::NotFound
          end
          response
        end
      end
    end
  end
end
