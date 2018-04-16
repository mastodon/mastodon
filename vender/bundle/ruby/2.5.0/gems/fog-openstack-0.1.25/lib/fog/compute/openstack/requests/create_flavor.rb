module Fog
  module Compute
    class OpenStack
      class Real
        # PARAMETERS #
        # name        = Name of flavor
        # ram         = Memory in MB
        # vcpus       = Number of VCPUs
        # disk        = Size of local disk in GB
        # swap        = Swap space in MB
        # rxtx_factor = RX/TX factor
        def create_flavor(attributes)
          # Get last flavor id
          flavor_ids = []
          flavors = list_flavors_detail.body['flavors'] + list_flavors_detail(:is_public => false).body['flavors']
          flavors.each do |flavor|
            flavor_ids << flavor['id'].to_i
          end

          # Set flavor id
          attributes[:flavor_id] = attributes[:flavor_id] || (!flavor_ids.empty? ? flavor_ids.sort.last + 1 : 1)

          data = {
            'flavor' => {
              'name'                       => attributes[:name],
              'ram'                        => attributes[:ram],
              'vcpus'                      => attributes[:vcpus],
              'disk'                       => attributes[:disk],
              'id'                         => attributes[:flavor_id],
              'swap'                       => attributes[:swap],
              'OS-FLV-EXT-DATA:ephemeral'  => attributes[:ephemeral],
              'os-flavor-access:is_public' => attributes[:is_public],
              'rxtx_factor'                => attributes[:rxtx_factor]
            }
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'POST',
            :path    => 'flavors'
          )
        end
      end

      class Mock
        def create_flavor(attributes)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-fdc6f99e-55a2-4ab1-8904-0892753828cf",
            "Content-Type"         => "application/json",
            "Content-Length"       => "356",
            "Date"                 => Date.new
          }
          response.body = {
            "flavor" => {
              "vcpus"                      => attributes[:vcpus],
              "disk"                       => attributes[:disk],
              "name"                       => attributes[:name],
              "links"                      => [
                {
                  "href" => "http://192.168.27.100:8774/v1.1/6733e93c5f5c4eb1bcabc6902ba208d6/flavors/11",
                  "rel"  => "self"
                },
                {
                  "href" => "http://192.168.27.100:8774/6733e93c5f5c4eb1bcabc6902ba208d6/flavors/11",
                  "rel"  => "bookmark"
                }
              ],
              "rxtx_factor"                => attributes[:rxtx_factor] || 1.0,
              "OS-FLV-EXT-DATA:ephemeral"  => attributes[:ephemeral] || 0,
              "os-flavor-access:is_public" => attributes[:is_public] || false,
              "OS-FLV-DISABLED:disabled"   => attributes[:disabled] || false,
              "ram"                        => attributes[:ram],
              "id"                         => "11",
              "swap"                       => attributes[:swap] || ""
            }
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
