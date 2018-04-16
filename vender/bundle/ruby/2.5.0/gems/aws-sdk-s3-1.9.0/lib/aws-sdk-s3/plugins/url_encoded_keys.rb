require 'uri'
require 'cgi'

module Aws
  module S3
    module Plugins

      # This plugin auto-populates the `:encoding_type` request parameter
      # to all calls made to Amazon S3 that accept it.
      #
      # This enables Amazon S3 to return object keys that might contain
      # invalid XML characters as URL encoded strings.  This plugin also
      # automatically decodes these keys so that the key management is
      # transparent to the user.
      #
      # If you specify the `:encoding_type` parameter, then this plugin
      # will be disabled, and you will need to decode the keys yourself.
      #
      # The following operations are managed:
      #
      # * {S3::Client#list_objects}
      # * {S3::Client#list_multipart_uploads}
      # * {S3::Client#list_object_versions}
      #
      class UrlEncodedKeys < Seahorse::Client::Plugin

        class Handler < Seahorse::Client::Handler

          def call(context)
            if context.params.key?(:encoding_type)
              @handler.call(context) # user managed
            else
              manage_keys(context)
            end
          end

          private

          def manage_keys(context)
            context.params[:encoding_type] = 'url'
            @handler.call(context).on_success do |resp|
              send("decode_#{resp.context.operation_name}_keys", resp.data)
            end
          end

          def decode_list_objects_keys(data)
            decode(:marker, data)
            decode(:next_marker, data)
            decode(:prefix, data)
            decode(:delimiter, data)
            data.contents.each { |o| decode(:key, o) } if data.contents
            data.common_prefixes.each { |o| decode(:prefix, o) } if data.common_prefixes
          end

          def decode_list_object_versions_keys(data)
            decode(:key_marker, data)
            decode(:next_key_marker, data)
            decode(:prefix, data)
            decode(:delimiter, data)
            data.versions.each { |o| decode(:key, o) } if data.versions
            data.delete_markers.each { |o| decode(:key, o) } if data.delete_markers
            data.common_prefixes.each { |o| decode(:prefix, o) } if data.common_prefixes
          end

          def decode_list_multipart_uploads_keys(data)
            decode(:key_marker, data)
            decode(:next_key_marker, data)
            decode(:prefix, data)
            decode(:delimiter, data)
            data.uploads.each { |o| decode(:key, o) } if data.uploads
            data.common_prefixes.each { |o| decode(:prefix, o) } if data.common_prefixes
          end

          def decode(member, struct)
            if struct[member]
              struct[member] = CGI.unescape(struct[member])
            end
          end

        end

        handler(Handler,
          step: :validate,
          priority: 0,
          operations: [
            :list_objects,
            :list_object_versions,
            :list_multipart_uploads,
          ]
        )

      end
    end
  end
end
