module Fog
  module Compute
    class OpenStack
      class Real
        def boot_from_snapshot(name, image_ref, flavor_ref, options = {})
          data = {
            'server' => {
              'flavorRef' => flavor_ref,
              'imageRef'  => image_ref,
              'name'      => name
            }
          }

          vanilla_options = ['metadata', 'accessIPv4', 'accessIPv6',
                             'availability_zone', 'user_data', 'block_device_mapping',
                             'key_name', 'security_groups']
          vanilla_options.select { |o| options[o] }.each do |key|
            data['server'][key] = options[key]
          end

          if options['personality']
            data['server']['personality'] = []
            options['personality'].each do |file|
              data['server']['personality'] << {
                'contents' => Base64.encode64(file['contents']),
                'path'     => file['path']
              }
            end
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => '/os-volumes_boot'
          )
        end
      end
    end # class OpenStack
  end # module Compute
end # module Fog
