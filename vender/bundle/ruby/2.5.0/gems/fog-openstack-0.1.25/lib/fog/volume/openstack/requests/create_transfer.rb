module Fog
  module Volume
    class OpenStack
      module Real
        def create_transfer(volume_id, options = {})
          data = {
            'transfer' => {
              'volume_id' => volume_id
            }
          }
          if options[:name]
            data['transfer']['name'] = options[:name]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => 'os-volume-transfer'
          )
        end
      end
    end
  end
end
