require 'fog/openstack/models/collection'
require 'fog/storage/openstack/models/file'

module Fog
  module Storage
    class OpenStack
      class Files < Fog::OpenStack::Collection
        attribute :directory
        attribute :limit
        attribute :marker
        attribute :path
        attribute :prefix

        model Fog::Storage::OpenStack::File

        def all(options = {})
          requires :directory
          options = {
            'limit'  => limit,
            'marker' => marker,
            'path'   => path,
            'prefix' => prefix
          }.merge!(options)
          merge_attributes(options)
          parent = directory.collection.get(
            directory.key,
            options
          )
          if parent
            # TODO: change to load_response?
            load(parent.files.map(&:attributes))
          end
        end

        alias each_file_this_page each
        def each
          if !block_given?
            self
          else
            subset = dup.all

            subset.each_file_this_page { |f| yield f }
            while subset.length == (subset.limit || 10000)
              subset = subset.all(:marker => subset.last.key)
              subset.each_file_this_page { |f| yield f }
            end

            self
          end
        end

        def get(key, &block)
          requires :directory
          data = service.get_object(directory.key, key, &block)
          file_data = data.headers.merge(:body => data.body,
                                         :key  => key)
          new(file_data)
        rescue Fog::Storage::OpenStack::NotFound
          nil
        end

        def get_url(key)
          requires :directory
          if directory.public_url
            "#{directory.public_url}/#{Fog::OpenStack.escape(key, '/')}"
          end
        end

        def get_http_url(key, expires, options = {})
          requires :directory
          service.get_object_http_url(directory.key, key, expires, options)
        end

        def get_https_url(key, expires, options = {})
          requires :directory
          service.get_object_https_url(directory.key, key, expires, options)
        end

        def head(key, _options = {})
          requires :directory
          data = service.head_object(directory.key, key)
          file_data = data.headers.merge(:key => key)
          new(file_data)
        rescue Fog::Storage::OpenStack::NotFound
          nil
        end

        def new(attributes = {})
          requires :directory
          super({:directory => directory}.merge!(attributes))
        end
      end
    end
  end
end
