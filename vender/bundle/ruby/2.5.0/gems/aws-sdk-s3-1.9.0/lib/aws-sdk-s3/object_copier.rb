require 'thread'

module Aws
  module S3
    # @api private
    class ObjectCopier

      # @param [S3::Object] object
      def initialize(object, options = {})
        @object = object
        @options = options.merge(client: @object.client)
      end

      def copy_from(source, options = {})
        copy_object(source, @object, merge_options(source, options))
      end

      def copy_to(target, options = {})
        copy_object(@object, target, merge_options(target, options))
      end

      private

      def copy_object(source, target, options)
        target_bucket, target_key = copy_target(target)
        options[:bucket] = target_bucket
        options[:key] = target_key
        options[:copy_source] = copy_source(source)
        if options.delete(:multipart_copy)
          apply_source_client(source, options)
          ObjectMultipartCopier.new(@options).copy(options)
        else
          @object.client.copy_object(options)
        end
      end

      def copy_source(source)
        case source
        when String then source
        when Hash
          src = "#{source[:bucket]}/#{escape(source[:key])}"
          src += "?versionId=#{source[:version_id]}" if source.key?(:version_id)
          src
        when S3::Object, S3::ObjectSummary
          "#{source.bucket_name}/#{escape(source.key)}"
        when S3::ObjectVersion
          "#{source.bucket_name}/#{escape(source.object_key)}?versionId=#{source.id}"
        else
          msg = "expected source to be an Aws::S3::Object, Hash, or String"
          raise ArgumentError, msg
        end
      end

      def copy_target(target)
        case target
        when String then target.match(/([^\/]+?)\/(.+)/)[1,2]
        when Hash then target.values_at(:bucket, :key)
        when S3::Object then [target.bucket_name, target.key]
        else
          msg = "expected target to be an Aws::S3::Object, Hash, or String"
          raise ArgumentError, msg
        end
      end

      def merge_options(source_or_target, options)
        if Hash === source_or_target
          source_or_target.inject(options.dup) do |opts, (key, value)|
            opts[key] = value unless [:bucket, :key, :version_id].include?(key)
            opts
          end
        else
          options.dup
        end
      end

      def apply_source_client(source, options)

        if source.respond_to?(:client)
          options[:copy_source_client] ||= source.client
        end

        if options[:copy_source_region]
          config = @object.client.config
          config = config.each_pair.inject({}) { |h, (k,v)| h[k] = v; h }
          config[:region] = options.delete(:copy_source_region)
          options[:copy_source_client] ||= S3::Client.new(config)
        end

        options[:copy_source_client] ||= @object.client

      end

      def escape(str)
        Seahorse::Util.uri_path_escape(str)
      end

    end
  end
end
