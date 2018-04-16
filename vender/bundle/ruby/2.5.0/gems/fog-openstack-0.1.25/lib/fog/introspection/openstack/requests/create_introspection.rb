module Fog
  module Introspection
    class OpenStack
      class Real
        def create_introspection(node_id, options = {})
          if options
            data = {
              'new_ipmi_username' => options[:new_ipmi_username],
              'new_ipmi_password' => options[:new_ipmi_password]
            }
            body = Fog::JSON.encode(data)
          else
            body = ""
          end

          request(
            :body    => body,
            :expects => 202,
            :method  => "POST",
            :path    => "introspection/#{node_id}"
          )
        end
      end

      class Mock
        def create_introspection(_node_id, _options = {})
          response = Excon::Response.new
          response.status = 202
          response.body = ""
          response
        end
      end
    end
  end
end
