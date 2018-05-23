require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v2/models/user'

module Fog
  module Identity
    class OpenStack
      class V2
        class Users < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V2::User

          attribute :tenant_id

          def all(options = {})
            options[:tenant_id] = tenant_id

            load_response(service.list_users(options), 'users')
          end

          def find_by_id(id)
            find { |user| user.id == id } ||
              Fog::Identity::OpenStack::V2::User.new(
                service.get_user_by_id(id).body['user'].merge(
                  'service' => service
                )
              )
          end

          def find_by_name(name)
            find { |user| user.name == name } ||
              Fog::Identity::OpenStack::V2::User.new(
                service.get_user_by_name(name).body['user'].merge(
                  'service' => service
                )
              )
          end

          def destroy(id)
            user = find_by_id(id)
            user.destroy
          end
        end # class Users
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog
