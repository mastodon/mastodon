module Fog
  module Compute
    class OpenStack
      class Real
        def delete_metadata(collection_name, parent_id, key)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "#{collection_name}/#{parent_id}/metadata/#{key}"
          )
        end
      end

      class Mock
        def delete_metadata(_collection_name, _parent_id, _key)
          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end
