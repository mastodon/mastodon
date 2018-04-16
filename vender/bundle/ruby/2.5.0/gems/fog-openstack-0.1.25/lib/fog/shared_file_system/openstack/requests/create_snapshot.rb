module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def create_snapshot(share_id, options = {})
          data = {
            'share_id' => share_id
          }

          vanilla_options = [
            :name, :description, :display_name, :display_description, :force
          ]

          vanilla_options.select { |o| options[o] }.each do |key|
            data[key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode('snapshot' => data),
            :expects => 202,
            :method  => 'POST',
            :path    => 'snapshots'
          )
        end
      end

      class Mock
        def create_snapshot(share_id, options = {})
          # stringify keys
          options = Hash[options.map { |k, v| [k.to_s, v] }]

          response = Excon::Response.new
          response.status = 202

          snapshot = data[:snapshots_detail].first.dup

          snapshot['share_id'] = share_id
          snapshot['status']   = 'creating'

          response.body = {'snapshot' => snapshot.merge(options)}
          response
        end
      end
    end
  end
end
