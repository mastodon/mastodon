module Fog
  module Storage
    class OpenStack
      class Real
        # Create a new dynamic large object manifest
        #
        # This is an alias for {#put_dynamic_obj_manifest} for backward compatibility.
        def put_object_manifest(container, object, options = {})
          put_dynamic_obj_manifest(container, object, options)
        end
      end
    end
  end
end
