require 'fog/openstack/models/collection'

module Fog
  module Volume
    class OpenStack
      module Volumes
        def all(options = {})
          # the parameter has been "detailed = true" before. Make sure we are
          # backwards compatible
          detailed = options.kind_of?(Hash) ? options.delete(:detailed) : options
          if detailed.nil? || detailed
            # This method gives details by default, unless false or {:detailed => false} is passed
            load_response(service.list_volumes_detailed(options), 'volumes')
          else
            Fog::Logger.deprecation('Calling OpenStack[:volume].volumes.all(false) or volumes.all(:detailed => false) '\
                                    ' is deprecated, call .volumes.summary instead')
            load_response(service.list_volumes(options), 'volumes')
          end
        end

        def summary(options = {})
          load_response(service.list_volumes(options), 'volumes')
        end

        def get(volume_id)
          if volume = service.get_volume_details(volume_id).body['volume']
            new(volume)
          end
        rescue Fog::Volume::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
