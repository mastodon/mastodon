module Fog
  module Volume
    class OpenStack
      # no Mock needed, test coverage in RSpec

      module Real
        def get_transfer_details(transfer_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "os-volume-transfer/#{transfer_id}"
          )
        end
      end
    end
  end
end
