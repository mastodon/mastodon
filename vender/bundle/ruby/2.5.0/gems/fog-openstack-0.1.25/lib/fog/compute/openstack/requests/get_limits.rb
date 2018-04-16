module Fog
  module Compute
    class OpenStack
      # http://developer.openstack.org/api-ref-compute-v2.1.html#showlimits

      class Real
        def get_limits(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => '/limits',
            :query   => options
          )
        end
      end

      class Mock
        def get_limits(_options = {})
          rate_limits = [
            {'regex' => '.*',
             'limit' => [
               {'next-available' => '2012-11-22T16:13:44Z',
                'unit'           => 'MINUTE',
                'verb'           => 'POST',
                'remaining'      => 9,
                'value'          => 10},
               {'next-available' => '2012-11-23T00:46:14Z',
                'unit'           => 'MINUTE',
                'verb'           => 'PUT',
                'remaining'      => 10,
                'value'          => 10},
               {'next-available' => '2012-11-22T16:14:30Z',
                'unit'           => 'MINUTE',
                'verb'           => 'DELETE',
                'remaining'      => 99,
                'value'          => 100}
             ],
             'uri'   => '*'},
            {'regex' => '^/servers',
             'limit' => [
               {'next-available' => '2012-11-23T00:46:14Z',
                'unit'           => 'DAY',
                'verb'           => 'POST',
                'remaining'      => 50,
                'value'          => 50}
             ],
             'uri'   => '*/servers'},
            {'regex' => '.*changes-since.*',
             'limit' => [
               {'next-available' => '2012-11-23T00:46:14Z',
                'unit'           => 'MINUTE',
                'verb'           => 'GET',
                'remaining'      => 3,
                'value'          => 3}
             ],
             'uri'   => '*changes-since*'}
          ]

          absolute_limits = {
            # Max
            'maxServerMeta'           => 128,
            'maxTotalInstances'       => 10,
            'maxPersonality'          => 5,
            'maxImageMeta'            => 128,
            'maxPersonalitySize'      => 10240,
            'maxSecurityGroupRules'   => 20,
            'maxTotalKeypairs'        => 100,
            'maxSecurityGroups'       => 10,
            'maxTotalCores'           => 20,
            'maxTotalFloatingIps'     => 10,
            'maxTotalRAMSize'         => 51200,

            # Used
            'totalCoresUsed'          => -1,
            'totalRAMUsed'            => -2048,
            'totalInstancesUsed'      => -1,
            'totalSecurityGroupsUsed' => 0,
            'totalFloatingIpsUsed'    => 0
          }

          Excon::Response.new(
            :status => 200,
            :body   => {
              'limits' => {
                'rate'     => rate_limits,
                'absolute' => absolute_limits
              }
            }
          )
        end
      end
    end
  end
end
