module Fog
  module Compute
    class OpenStack
      class Real
        # Retrieve server actions.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to query for available actions.
        # === Returns
        # * actions <~Array>
        def server_actions(server_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "servers/#{server_id}/os-instance-actions"
          ).body['instanceActions']
        end # def server_actions
      end # class Real

      class Mock
        def server_actions(server_id)
          response = Excon::Response.new
          response.status = 200
          response.body = [{
            'instance_uuid' => server_id,
            'user_id'       => '7067d67a2b23435ca2366588680b66c3',
            'start_time'    => Time.now.iso8601,
            'request_id'    => "req-#{server_id}",
            'action'        => 'stop',
            'message'       => nil,
            'project_id'    => '9d5d0b877cf449fdae078659cfa12e86'
          }]
          response
        end # def server_actions
      end # class Mock
    end # class OpenStack
  end # module Compute
end # moduel Fog
