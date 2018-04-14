module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def get_limits
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'limits'
          )
        end
      end

      class Mock
        def get_limits
          absolute_limits = {
            # Max
            'maxTotalShareGigabytes'     => 1000,
            'maxTotalShareNetworks'      => 10,
            'maxTotalShares'             => 50,
            'maxTotalSnapshotGigabytes'  => 1000,
            'maxTotalShareSnapshots'     => 50,

            # Used
            'totalShareNetworksUsed'     => 0,
            'totalSharesUsed'            => 0,
            'totalShareGigabytesUsed'    => 0,
            'totalShareSnapshotsUsed'    => 0,
            'totalSnapshotGigabytesUsed' => 0
          }

          Excon::Response.new(
            :status => 200,
            :body   => {
              'limits' => {
                'rate'     => [],
                'absolute' => absolute_limits
              }
            }
          )
        end
      end
    end
  end
end
