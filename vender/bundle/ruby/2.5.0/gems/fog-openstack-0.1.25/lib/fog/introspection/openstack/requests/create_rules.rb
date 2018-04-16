module Fog
  module Introspection
    class OpenStack
      class Real
        def create_rules(attributes)
          attributes_valid = [
            :actions,
            :conditions,
            :uuid,
            :description
          ]

          # Filter only allowed creation attributes
          data = attributes.select do |key, _|
            attributes_valid.include?(key.to_sym)
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => "POST",
            :path    => "rules"
          )
        end
      end

      class Mock
        def create_rules(_)
          response = Excon::Response.new
          response.status = 200
          response.body = {"rules" => data[:rules].first}
          response
        end
      end
    end
  end
end
