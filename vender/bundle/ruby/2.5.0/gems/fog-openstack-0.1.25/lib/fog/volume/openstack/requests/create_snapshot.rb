module Fog
  module Volume
    class OpenStack
      module Real
        private

        def _create_snapshot(data)
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => "snapshots"
          )
        end
      end
    end
  end
end
