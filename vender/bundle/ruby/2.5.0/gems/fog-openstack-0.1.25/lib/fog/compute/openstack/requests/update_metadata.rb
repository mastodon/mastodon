module Fog
  module Compute
    class OpenStack
      class Real
        def update_metadata(collection_name, parent_id, metadata = {})
          request(
            :body    => Fog::JSON.encode('metadata' => metadata),
            :expects => 200,
            :method  => 'POST',
            :path    => "#{collection_name}/#{parent_id}/metadata"
          )
        end
      end

      class Mock
        def update_metadata(collection_name, parent_id, metadata = {})
          if collection_name == "images"
            unless list_images_detail.body['images'].find { |image| image['id'] == parent_id }
              raise Fog::Compute::OpenStack::NotFound
            end
          end

          if collection_name == "servers"
            unless list_servers_detail.body['servers'].find { |server| server['id'] == parent_id }
              raise Fog::Compute::OpenStack::NotFound
            end
          end

          # FIXME: join w/ existing metadata here
          response = Excon::Response.new
          response.body = {"metadata" => metadata}
          response.status = 200
          response
        end
      end
    end
  end
end
