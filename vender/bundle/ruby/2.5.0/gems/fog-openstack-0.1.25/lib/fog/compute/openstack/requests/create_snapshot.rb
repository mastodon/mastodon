module Fog
  module Compute
    class OpenStack
      class Real
        def create_snapshot(volume_id, name, description, force = false)
          data = {
            'snapshot' => {
              'volume_id'           => volume_id,
              'display_name'        => name,
              'display_description' => description,
              'force'               => force
            }
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => "os-snapshots"
          )
        end
      end

      class Mock
        def create_snapshot(volume_id, name, description, _force = false)
          volume_response = get_volume_details(volume_id)
          volume = volume_response.data[:body]['volume']
          if volume.nil?
            raise Fog::Compute::OpenStack::NotFound
          else
            response = Excon::Response.new
            data = {
              "status"      => "availble",
              "name"        => name,
              "created_at"  => Time.now,
              "description" => description,
              "volume_id"   => volume_id,
              "id"          => Fog::Mock.random_numbers(2),
              "size"        => volume['size']
            }

            self.data[:snapshots][data['id']] = data
            response.body = {"snapshot" => data}
            response.status = 202
            response
          end
        end
      end
    end
  end
end
