module Fog
  module NFV
    class OpenStack
      class Real
        def create_vnf(options)
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
            :expects => 201,
            :method  => "POST",
            :path    => "vnfs"
          )
        end
      end

      class Mock
        def create_vnf(_)
          response = Excon::Response.new
          response.status = 201

          create_data = data[:vnfs].first.merge("vnfd_id" => "id")
          response.body = {"vnf" => create_data}
          response
        end
      end
    end
  end
end
