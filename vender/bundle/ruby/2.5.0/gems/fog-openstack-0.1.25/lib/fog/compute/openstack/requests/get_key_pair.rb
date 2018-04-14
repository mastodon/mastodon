module Fog
  module Compute
    class OpenStack
      class Real
        def get_key_pair(key_name)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "os-keypairs/#{Fog::OpenStack.escape(key_name)}"
          )
        end
      end

      class Mock
        def delete_key_pair(key_name)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-c373a42c-2825-4e60-8d34-99416ea850be",
            "Content-Type"         => "application/json",
            "Content-Length"       => "1289",
            "Date"                 => Date.new
          }
          response.body = {
            "keypair" => {
              "public_key"  => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDCdAZLjljntJbLVVkNHjWFSoKen2nZbk39ZfqhZJOMdeFdz"\
                               "02GWBS45rcuboeGg/gozKRwsLu4N6NLPlYtbK/NapJIvgO/djBp+FQG1QZNtLPsx7j4hVJac3yISGms+Xtu4c"\
                               "Ev6j5sFDzAgTQbWez0Z1+9qOq9ngdaoW+YClfQ== vagrant@nova\n",
              "private_key" => "-----BEGIN RSA PRIVATE KEY-----\nMIICXgIBAAKBgQDCdAZLjljn1tJbLVVkNHjWFSoKen2nZbk39Zfq"\
                               "hZJOMdeFdz02\nGWBS45rcuHboeGg/gozKRwsLu4N6NLPlYtbK/NapJIvgO/djBp+FQG1QZNtLPsx7\nj4hVJ"\
                               "ac3yISGms+Xtu4cEv6j5sFDzAgTQbWez0Z1+9qOq9ngdaoW+YClfQIDAQAB\nAoGBALBoT9m1vuQ82EONQf2R"\
                               "ONqHAsfUzi/SMhEZRgOlv9AemXZkcWyl4uPvxmtd\nEcreiTystAtCHjw7lhCExXthipevUjtIAAt+b3pMn6O"\
                               "yjad3IRvde6atMdjrje43\n/nftYtuXYyJTsvwEvLYqSioLQ0Nn/XDKhOpcM5tejDHOH35lAkEA+H4r7y9X52"\
                               "1u\nIABVAezBWaT/wvdMjx5cwfyYEQjnI1bxfRIqkgoY5gDDBdVbT75UTsHHbHLORQcw\nRjRvS2zgewJBAMh"\
                               "T6eyMonJvHHvC5RcchcY+dWkscIKoOzeyUKMb+7tERQa9/UN2\njYb+jdM0VyL0ruLFwYtl2m34gfmhcXgIvG"\
                               "cCQGzKMEnjHEUBr7jq7EyPbobkqeSd\niDMQQ+PZxmmO0EK0ib0L+v881HG926PuKK/cz+Q7Cif8iznFT+ksg"\
                               "50t6YkCQQC9\nwfcAskqieSuS9A9LcCIrojhXctf0e+T0Ij2N89DlF4sHEuqXf/IZ4IB5gsfTfdE3\nUDnAkK"\
                               "9yogaEbu/r0uKbAkEAy5kl71bIqvKTKsY2mES9ziVxfftl/9UIi5LI+QHb\nmC/c6cTrGVCM71fi2GMxGgBeE"\
                               "ea4+7xwoWTL4CxA00kmTg==\n-----END RSA PRIVATE KEY-----\n",
              "user_id"     => "admin",
              "name"        => key_name,
              "fingerprint" => "97:86:f4:15:68:0c:7b:a7:e5:8f:f0:bd:1f:27:65:ad"
            }
          }
          response
        end
      end
    end
  end
end
