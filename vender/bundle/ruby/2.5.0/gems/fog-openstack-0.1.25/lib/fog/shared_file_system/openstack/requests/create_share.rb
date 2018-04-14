module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def create_share(protocol, size, options = {})
          data = {
            'share_proto' => protocol,
            'size'        => size
          }

          vanilla_options = [
            :name, :description, :display_name, :display_description, :share_type, :volume_type, :snapshot_id,
            :is_public, :metadata, :share_network_id, :consistency_group_id, :availability_zone
          ]

          vanilla_options.select { |o| options[o] }.each do |key|
            data[key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode('share' => data),
            :expects => 200,
            :method  => 'POST',
            :path    => 'shares'
          )
        end
      end

      class Mock
        def create_share(protocol, size, options = {})
          # stringify keys
          options = Hash[options.map { |k, v| [k.to_s, v] }]

          response = Excon::Response.new
          response.status = 200

          share = data[:shares_detail].first.dup

          share['share_proto'] = protocol
          share['size']        = size
          share['status']      = 'creating'

          response.body = {'share' => share.merge(options)}
          response
        end
      end
    end
  end
end
