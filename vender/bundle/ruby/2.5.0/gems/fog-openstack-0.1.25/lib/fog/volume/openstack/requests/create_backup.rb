module Fog
  module Volume
    class OpenStack
      module Real
        def create_backup(attributes)
          desired_options = [
            :container,
            :name,
            :description,
            :volume_id,
            :incremental,
            :force,
          ]

          # Filter only allowed creation attributes
          data = {
            :backup => attributes.select { |key, _value| desired_options.include?(key.to_sym) }
          }

          request(
            :body => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method => 'POST',
            :path => 'backups'
          )
        end
      end

      module Mock
        def create_backup(_options = {})
          response = Excon::Response.new
          response.status = 202
          response.body = {
            "backup" => {
              "id" => "1",
              "volume_id" => "2",
              "name" => "backup 1",
              "status" => "available",
              "size" => 1,
              "object_count" => 16,
              "container" => "testcontainer",
            }
          }
          response
        end
      end
    end
  end
end
