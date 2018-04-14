require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class OsCredential < Fog::OpenStack::Model
          identity :id

          attribute :project_id
          attribute :type
          attribute :blob
          attribute :user_id
          attribute :links

          def to_s
            name
          end

          def destroy
            requires :id
            service.delete_os_credential(id)
            @parsed_blob = nil
            true
          end

          def update(attr = nil)
            requires :id
            merge_attributes(
              service.update_os_credential(id, attr || attributes).body['credential']
            )
            @parsed_blob = nil
            self
          end

          def save
            requires :blob, :type
            @parsed_blob = nil
            identity ? update : create
          end

          def create
            merge_attributes(
              service.create_os_credential(attributes).body['credential']
            )
            @parsed_blob = nil
            self
          end

          def parsed_blob
            @parsed_blob = ::JSON.parse(blob) unless @parsed_blob
            @parsed_blob
          end

          def name
            parsed_blob['name'] if blob
          end

          def public_key
            parsed_blob['public_key'] if blob
          end

          def fingerprint
            parsed_blob['fingerprint'] if blob
          end

          def private_key
            parsed_blob['private_key'] if blob
          end
        end
      end
    end
  end
end
