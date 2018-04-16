module Fog
  module Compute
    class OpenStack
      class Real
        def create_image(server_id, name, metadata = {})
          body = {'createImage' => {
            'name'     => name,
            'metadata' => metadata
          }}
          data = server_action(server_id, body)
          image_id = data.headers["Location"].scan(%r{.*/(.*)}).flatten[0]
          get_image_details(image_id)
        end
      end

      class Mock
        def create_image(server_id, name, metadata = {})
          response = Excon::Response.new
          response.status = 202

          img_id = Fog::Mock.random_numbers(6).to_s

          data = {
            'id'       => img_id,
            'server'   => {"id" => "3", "links" => [{"href" => "http://nova1:8774/admin/servers/#{server_id}", "rel" => "bookmark"}]},
            'links'    => [{"href" => "http://nova1:8774/v1.1/admin/images/#{img_id}", "rel" => "self"}, {"href" => "http://nova1:8774/admin/images/#{img_id}", "rel" => "bookmark"}],
            'metadata' => metadata || {},
            'name'     => name || "server_#{rand(999)}",
            'progress' => 0,
            'status'   => 'SAVING',
            'minDisk'  => 0,
            'minRam'   => 0,
            'updated'  => "",
            'created'  => ""
          }
          self.data[:last_modified][:images][data['id']] = Time.now
          self.data[:images][data['id']] = data
          response.body = {'image' => data}
          response
        end
      end
    end
  end
end
