#
module Fog
  module Compute
    class OpenStack
      #
      class Real
        def create_volume(name, description, size, options = {})
          data = {
            'volume' => {
              'display_name'        => name,
              'display_description' => description,
              'size'                => size
            }
          }

          vanilla_options = [
            :snapshot_id,
            :availability_zone,
            :volume_type,
            :metadata
          ]

          vanilla_options.select { |o| options[o] }.each do |key|
            data['volume'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => 'os-volumes'
          )
        end
      end

      #
      class Mock
        def create_volume(name, description, size, options = {})
          response = Excon::Response.new
          response.status = 202
          data = {'id' => Fog::Mock.random_numbers(2),
                  'displayName' => name,
                  'displayDescription' => description,
                  'size' => size,
                  'status' => 'creating',
                  'snapshotId' => options[:snapshot_id],
                  'volumeType' => options[:volume_type] || 'None',
                  'availabilityZone' => options[:availability_zone] || 'nova',
                  'createdAt' => Time.now.strftime('%FT%T.%6N'),
                  'attachments' => [], 'metadata' => options[:metadata] || {}}
          self.data[:volumes][data['id']] = data
          response.body = {'volume' => data}
          response
        end
      end
    end
  end
end
