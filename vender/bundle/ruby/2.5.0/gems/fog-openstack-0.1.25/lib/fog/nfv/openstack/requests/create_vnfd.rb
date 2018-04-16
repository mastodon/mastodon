module Fog
  module NFV
    class OpenStack
      class Real
        def create_vnfd(options)
          options_valid = [
            :auth,
            :vnfd,
          ]

          # Filter only allowed creation attributes
          data = options.select do |key, _|
            options_valid.include?(key.to_sym) || options_valid.include?(key.to_s)
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 201,
            :method  => "POST",
            :path    => "vnfds"
          )
        end
      end

      class Mock
        def create_vnfd(_)
          response = Excon::Response.new
          response.status = 201
          response.body = {"vnfd" => data[:vnfds].first}
          response
        end
      end
    end
  end
end
