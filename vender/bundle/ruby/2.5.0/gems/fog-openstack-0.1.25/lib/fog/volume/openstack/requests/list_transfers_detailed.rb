module Fog
  module Volume
    class OpenStack
      # no Mock needed, test coverage in RSpec

      module Real
        def list_transfers_detailed(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-volume-transfer/detail',
            :query   => options
          )
        end
      end
    end
  end
end
