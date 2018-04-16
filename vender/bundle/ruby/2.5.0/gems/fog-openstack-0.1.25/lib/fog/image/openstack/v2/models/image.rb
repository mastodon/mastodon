require 'fog/openstack/models/model'

module Fog
  module Image
    class OpenStack
      class V2
        class Image < Fog::OpenStack::Model
          identity :id

          attribute :name
          attribute :visibility # public or private

          attribute :tags

          attribute :self
          attribute :size
          attribute :virtual_size
          attribute :disk_format
          attribute :container_format
          attribute :id
          attribute :checksum
          attribute :self
          attribute :file

          # detailed
          attribute :min_disk
          attribute :created_at
          attribute :updated_at
          attribute :protected
          attribute :status # "queued","saving","active","killed","deleted","pending_delete"
          attribute :min_ram
          attribute :owner
          attribute :properties
          attribute :metadata
          attribute :location

          # from snapshot support
          attribute :network_allocated
          attribute :base_image_ref
          attribute :image_type
          attribute :instance_uuid
          attribute :user_id

          def method_missing(method_sym, *arguments, &block)
            if attributes.key?(method_sym)
              attributes[method_sym]
            elsif attributes.key?(method_sym.to_s)
              attributes[method_sym.to_s]
            elsif method_sym.to_s.end_with?('=')
              attributes[method_sym.to_s.gsub(/=$/, '')] = arguments[0]
            else
              super
            end
          end

          def respond_to?(method_sym, include_all = false)
            if attributes.key?(method_sym)
              true
            elsif attributes.key?(method_sym.to_s)
              true
            elsif method_sym.to_s.end_with?('=')
              true
            else
              super
            end
          end

          def create
            requires :name
            merge_attributes(service.create_image(attributes).body)
            self
          end

          # Here we convert 'attributes' into a form suitable for Glance's usage of JSON Patch (RFC6902).
          #  We fetch the existing attributes from the server to compute the delta (difference)
          #  Setting value to nil will delete that attribute from the server.
          def update(attr = nil)
            requires :id
            client_attributes = attr || @attributes
            server_attributes = service.images.get(id).attributes

            json_patch = build_update_json_patch(client_attributes, server_attributes)

            merge_attributes(
              service.update_image(id, json_patch).body
            )
            self
          end

          # This overrides the behaviour of Fog::OpenStack::Model::save() which tries to be clever and
          #  assumes save=update if an ID is present - but Image V2 allows ID to be specified on creation
          def save
            if @attributes[:self].nil?
              create
            else
              update
            end
          end

          def destroy
            requires :id
            service.delete_image(id)
            true
          end

          def upload_data(io_obj)
            requires :id
            if io_obj.kind_of? Hash
              service.upload_image(id, nil, io_obj)
            else
              service.upload_image(id, io_obj)
            end
          end

          def download_data(params = {})
            requires :id
            service.download_image(id, params[:content_range], params)
          end

          def reactivate
            requires :id
            service.reactivate_image(id)
          end

          def deactivate
            requires :id
            service.deactivate_image(id)
          end

          def add_member(member_id)
            requires :id
            service.add_member_to_image(id, member_id)
          end

          def remove_member(member_id)
            requires :id
            service.remove_member_from_image(id, member_id)
          end

          def update_member(member)
            requires :id
            service.update_image_member(id, member)
          end

          def members
            requires :id
            service.get_image_members(id).body['members']
          end

          def member(member_id)
            requires :id
            service.get_member_details(id, member_id)
          end

          def add_tags(tags)
            requires :id
            tags.each { |tag| add_tag tag }
          end

          def add_tag(tag)
            requires :id
            service.add_tag_to_image(id, tag)
          end

          def remove_tags(tags)
            requires :id
            tags.each { |tag| remove_tag tag }
          end

          def remove_tag(tag)
            requires :id
            service.remove_tag_from_image(id, tag)
          end

          private

          def build_update_json_patch(client_attributes, server_attributes)
            [
              build_patch_operation('remove', patch_attributes_to_remove(client_attributes, server_attributes)),
              build_patch_operation('add', patch_attributes_to_add(client_attributes, server_attributes)),
              build_patch_operation('replace', patch_attributes_to_replace(client_attributes, server_attributes)),
            ].flatten
          end

          def patch_attributes_to_remove(client_attributes, server_attributes)
            client_attributes.select do |key, value|
              value.nil? && !server_attributes[key].nil?
            end
          end

          def patch_attributes_to_add(client_attributes, server_attributes)
            client_attributes.reject do |key, _|
              server_attributes.key?(key)
            end
          end

          def patch_attributes_to_replace(client_attributes, server_attributes)
            client_attributes.reject do |key, value|
              value.nil? || server_attributes[key] == value
            end
          end

          def build_patch_operation(op_name, attributes)
            json_patch = []
            attributes.each do |key, value|
              json_patch << {:op => op_name, :path => "/#{key}", :value => value}
            end
            json_patch
          end
        end
      end
    end
  end
end
