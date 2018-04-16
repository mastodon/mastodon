module Fog
  module Workflow
    class OpenStack
      class V2
        class Real
          def update_execution(id, name, value)
            # valid values for name are:
            # state, description, env
            # https://github.com/openstack/python-mistralclient/blob/master/mistralclient/commands/v2/executions.py
            data = {:id => id}
            data[name] = Fog::JSON.encode(value)
            body = Fog::JSON.encode(data)
            request(
              :body    => body,
              :expects => 200,
              :method  => "PUT",
              :path    => "executions"
            )
          end
        end

        class Mock
          def update_execution(_id, _name, _value)
            response = Excon::Response.new
            response.status = 200
            response.body = ""
            response
          end
        end
      end
    end
  end
end
