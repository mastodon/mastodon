module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def create_zone(name, email, options = {})
            data = {
              'name'  => name,
              'email' => email
            }

            vanilla_options = [:ttl, :description, :type, :masters, :attributes]

            vanilla_options.select { |o| options[o] }.each do |key|
              data[key] = options[key]
            end

            request(
              :body    => Fog::JSON.encode(data),
              :expects => 202,
              :method  => 'POST',
              :path    => "zones"
            )
          end
        end

        class Mock
          def create_zone(name, email, options = {})
            # stringify keys
            options = Hash[options.map { |k, v| [k.to_s, v] }]

            response = Excon::Response.new
            response.status = 202

            zone = data[:zones].first.dup

            zone["name"]          = name
            zone["email"]         = email
            zone["status"]        = "PENDING"
            zone["action"]        = "CREATE"

            response.body = zone.merge(options)
            response
          end
        end
      end
    end
  end
end
