module Fog
  module Compute
    class OpenStack
      class Real
        def list_key_pairs(options = {})
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => 'os-keypairs',
            :query   => options
          )
        end
      end

      class Mock
        def list_key_pairs(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-c373a42c-2825-4e60-8d34-99416ea850be",
            "Content-Type"         => "application/json",
            "Content-Length"       => "360",
            "Date"                 => Date.new
          }
          response.body = {
            "keypairs" => [{
              "keypair" => {
                "public_key"  => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDCdAZLjln1tJbLVVkNHjWFSoKen2nZbk39ZfqhZJOMdeFdz02GWBS4rcuHboeGg/gozKRwsLu4N6NLPlYtbK/NapJIvgO/djBp+FG1QZNtLPsx7j4hVJac3yISGms+Xtu4cEv6j5sFDzAgTQbWz0Z1+9qOq9ngdaoW+YClfQ== vagrant@nova\n",
                "name"        => "test_key",
                "fingerprint" => "97:86:f4:15:68:0c:7b:a7:e5:8f:f0:bd:1f:27:65:ad"
              }
            }]
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
