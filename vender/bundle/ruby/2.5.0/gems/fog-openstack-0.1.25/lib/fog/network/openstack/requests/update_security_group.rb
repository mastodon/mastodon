module Fog
  module Network
    class OpenStack
      class Real
        def update_security_group(security_group_id, options = {})
          data = {'security_group' => {}}

          [:name, :description].each do |key|
            data['security_group'][key] = options[key] if options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "security-groups/#{security_group_id}"
          )
        end
      end

      class Mock
        def update_security_group(security_group_id, options = {})
          response = Excon::Response.new
          security_group = list_security_groups.body['security_groups'].find do |sg|
            sg['id'] == security_group_id
          end

          if security_group
            security_group['name']        = options[:name]
            security_group['description'] = options[:description]
            response.body = {'security_group' => security_group}
            response.status = 200
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
