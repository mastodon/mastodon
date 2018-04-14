module Fog
  module Compute
    class OpenStack
      class Real
        def delete_meta(collection_name, parent_id, key)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "#{collection_name}/#{parent_id}/metadata/#{key}"
          )
        end
      end

      class Mock
        def delete_meta(collection_name, parent_id, _key)
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

          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end
