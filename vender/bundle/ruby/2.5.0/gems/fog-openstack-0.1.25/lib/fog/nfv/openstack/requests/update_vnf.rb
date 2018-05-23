module Fog
  module NFV
    class OpenStack
      class Real
        def update_vnf(id, options)
          options_valid = [
            :auth,
            :vnf,
          ]

          # Filter only allowed creation attributes
          data = options.select do |key, _|
            options_valid.include?(key.to_sym) || options_valid.include?(key.to_s)
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => "PUT",
            :path    => "vnfs/#{id}"
          )
        end
      end

      class Mock
        def update_vnf(_, _)
          response = Excon::Response.new
          response.status = 200
          response.body = {"vnf" => data[:vnfs].first}
          response
        end
      end
    end
  end
end
