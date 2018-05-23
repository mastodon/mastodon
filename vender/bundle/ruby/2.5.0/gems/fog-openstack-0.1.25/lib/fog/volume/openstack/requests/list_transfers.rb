module Fog
  module Volume
    class OpenStack
      # no Mock needed, test coverage in RSpec

      module Real
        def list_transfers(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-volume-transfer',
            :query   => options
          )
        end
      end
    end
  end
end
