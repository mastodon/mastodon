module Fog
  module Volume
    class OpenStack
      module Real
        def snapshot_action(id, data)
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => "snapshots/#{id}/action"
          )
        end
      end
    end
  end
end
