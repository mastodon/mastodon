module Fog
  module Network
    class OpenStack
      class Real
        def list_ike_policies(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'vpn/ikepolicies',
            :query   => filters
          )
        end
      end

      class Mock
        def list_ike_policies(*)
          Excon::Response.new(
            :body   => {'ikepolicies' => data[:ike_policies].values},
            :status => 200
          )
        end
      end
    end
  end
end
