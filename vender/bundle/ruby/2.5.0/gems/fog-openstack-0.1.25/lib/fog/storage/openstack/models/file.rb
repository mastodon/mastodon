require 'fog/openstack/models/model'

module Fog
  module Storage
    class OpenStack
      class File < Fog::OpenStack::Model
        identity  :key,             :aliases => 'name'

        attribute :access_control_allow_origin, :aliases => ['Access-Control-Allow-Origin']
        attribute :content_length,  :aliases => ['bytes', 'Content-Length'], :type => :integer
        attribute :content_type,    :aliases => ['content_type', 'Content-Type']
        attribute :content_disposition, :aliases => ['content_disposition', 'Content-Disposition']
        attribute :etag,            :aliases => ['hash', 'Etag']
        attribute :last_modified,   :aliases => ['last_modified', 'Last-Modified'], :type => :time
        attribute :metadata
        attribute :origin,          :aliases => ['Origin']
        # @!attribute [rw] delete_at
        # A Unix Epoch Timestamp, in integer form, representing the time when this object will be automatically deleted.
        # @return [Integer] the unix epoch timestamp of when this object will be automatically deleted
        # @see http://docs.openstack.org/developer/swift/overview_expiring_objects.html
        attribute :delete_at, :aliases => ['X-Delete-At']

        # @!attribute [rw] delete_after
        # A number of seconds representing how long from now this object will be automatically deleted.
        # @return [Integer] the number of seconds until this object will be automatically deleted
        # @see http://docs.openstack.org/developer/swift/overview_expiring_objects.html
        attribute :delete_after, :aliases => ['X-Delete-After']

        # @!attribute [rw] content_encoding
        # When you create an object or update its metadata, you can optionally set the Content-Encoding metadata.
        # This metadata enables you to indicate that the object content is compressed without losing the identity of the
        # underlying media type (Content-Type) of the file, such as a video.
        # @see http://docs.openstack.org/developer/swift/api/use_content-encoding_metadata.html#use-content-encoding-metadata
        attribute :content_encoding, :aliases => 'Content-Encoding'

        def initialize(new_attributes = {})
          super
          @dirty = if last_modified then false else true end
        end

        def body
          attributes[:body] ||= if last_modified
                                  collection.get(identity).try(:body) || ''
                                else
                                  ''
                                end
        end

        def body=(new_body)
          attributes[:body] = new_body
          @dirty = true
        end

        attr_reader :directory

        def copy(target_directory_key, target_file_key, options = {})
          requires :directory, :key
          options['Content-Type'] ||= content_type if content_type
          options['Access-Control-Allow-Origin'] ||= access_control_allow_origin if access_control_allow_origin
          options['Origin'] ||= origin if origin
          options['Content-Encoding'] ||= content_encoding if content_encoding
          service.copy_object(directory.key, key, target_directory_key, target_file_key, options)
          target_directory = service.directories.new(:key => target_directory_key)
          target_directory.files.get(target_file_key)
        end

        def destroy
          requires :directory, :key
          service.delete_object(directory.key, key)
          @dirty = true
          true
        end

        def metadata
          attributes[:metadata] ||= headers_to_metadata
        end

        def owner=(new_owner)
          if new_owner
            attributes[:owner] = {
              :display_name => new_owner['DisplayName'],
              :id           => new_owner['ID']
            }
          end
        end

        def public=(new_public)
          new_public
        end

        # Get a url for file.
        #
        #     required attributes: key
        #
        # @param expires [String] number of seconds (since 1970-01-01 00:00) before url expires
        # @param options [Hash]
        # @return [String] url
        #
        def url(expires, options = {})
          requires :directory, :key
          service.create_temp_url(directory.key, key, expires, "GET", options)
        end

        def public_url
          requires :key
          collection.get_url(key)
        end

        def save(options = {})
          requires :directory, :key
          options['Content-Type'] = content_type if content_type
          options['Content-Disposition'] = content_disposition if content_disposition
          options['Access-Control-Allow-Origin'] = access_control_allow_origin if access_control_allow_origin
          options['Origin'] = origin if origin
          options['X-Delete-At'] = delete_at if delete_at
          options['X-Delete-After'] = delete_after if delete_after
          options['Content-Encoding'] = content_encoding if content_encoding
          options.merge!(metadata_to_headers)

          if not @dirty
            data = service.post_object(directory.key, key, options)
          else
            requires :body
            data = service.put_object(directory.key, key, body, options)
            self.content_length = Fog::Storage.get_body_size(body)
            self.content_type ||= Fog::Storage.get_content_type(body)
          end
          update_attributes_from(data)
          refresh_metadata

          true
        end

        private

        attr_writer :directory

        def refresh_metadata
          metadata.reject! { |_k, v| v.nil? }
        end

        def headers_to_metadata
          key_map = key_mapping
          Hash[metadata_attributes.map { |k, v| [key_map[k], v] }]
        end

        def key_mapping
          key_map = metadata_attributes
          key_map.each_pair { |k, _v| key_map[k] = header_to_key(k) }
        end

        def header_to_key(opt)
          opt.gsub(metadata_prefix, '').split('-').map { |k| k[0, 1].downcase + k[1..-1] }.join('_').to_sym
        end

        def metadata_to_headers
          header_map = header_mapping
          Hash[metadata.map { |k, v| [header_map[k], v] }]
        end

        def header_mapping
          header_map = metadata.dup
          header_map.each_pair { |k, _v| header_map[k] = key_to_header(k) }
        end

        def key_to_header(key)
          metadata_prefix + key.to_s.split(/[-_]/).map(&:capitalize).join('-')
        end

        def metadata_attributes
          if last_modified
            headers = service.head_object(directory.key, key).headers
            headers.reject! { |k, _v| !metadata_attribute?(k) }
          else
            {}
          end
        end

        def metadata_attribute?(key)
          key.to_s =~ /^#{metadata_prefix}/
        end

        def metadata_prefix
          "X-Object-Meta-"
        end

        def update_attributes_from(data)
          merge_attributes(data.headers.reject { |key, _value| ['Content-Length', 'Content-Type'].include?(key) })
        end
      end
    end
  end
end
