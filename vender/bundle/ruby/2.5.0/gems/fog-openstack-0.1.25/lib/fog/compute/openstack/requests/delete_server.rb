module Fog
  module Compute
    class OpenStack
      class Real
        def delete_server(server_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "servers/#{server_id}"
          )
        end
      end

      class Mock
        def delete_server(server_id)
          response = Excon::Response.new
          server = list_servers_detail.body['servers'].find { |srv| srv['id'] == server_id }
          if server
            if server['status'] == 'BUILD'
              response.status = 409
              raise(Excon::Errors.status_error({:expects => 204}, response))
            else
              data[:last_modified][:servers].delete(server_id)
              data[:servers].delete(server_id)
              response.status = 204
              server_groups = data[:server_groups]
              if server_groups
                group_id, = server_groups.find { |_id, grp| grp[:members].include?(server_id) }
                server_groups[group_id][:members] -= [server_id] if group_id
              end
            end
            response
          else
            raise Fog::Compute::OpenStack::NotFound
          end
        end
      end
    end
  end
end
