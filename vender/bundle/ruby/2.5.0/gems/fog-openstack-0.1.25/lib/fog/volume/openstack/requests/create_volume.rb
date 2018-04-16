module Fog
  module Volume
    class OpenStack
      module Real
        private

        def _create_volume(data, options = {})
          vanilla_options = [:snapshot_id, :imageRef, :volume_type,
                             :source_volid, :availability_zone, :metadata]
          vanilla_options.select { |o| options[o] }.each do |key|
            data['volume'][key] = options[key]
          end
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => "volumes"
          )
        end
      end
    end
  end
end
