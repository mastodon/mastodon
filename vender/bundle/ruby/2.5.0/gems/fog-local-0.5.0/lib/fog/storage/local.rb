module Fog
  module Storage
    class Local < Fog::Service
      autoload :Directories, ::File.expand_path('../local/models/directories', __FILE__)
      autoload :Directory, ::File.expand_path('../local/models/directory', __FILE__)
      autoload :File, ::File.expand_path('../local/models/file', __FILE__)
      autoload :Files, ::File.expand_path('../local/models/files', __FILE__)

      requires :local_root
      recognizes :endpoint, :scheme, :host, :port, :path

      model_path 'fog/storage/local/models'
      collection  :directories
      model       :directory
      model       :file
      collection  :files

      require 'uri'

      class Mock
        attr_reader :endpoint

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {}
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options={})
          Fog::Mock.not_implemented

          @local_root = ::File.expand_path(options[:local_root])

          @endpoint = options[:endpoint] || build_endpoint_from_options(options)
        end

        def data
          self.class.data[@local_root]
        end

        def local_root
          @local_root
        end

        def path_to(partial)
          ::File.join(@local_root, partial)
        end

        def reset_data
          self.class.data.delete(@local_root)
        end

        private
        def build_endpoint_from_options(options)
          return unless options[:host]

          URI::Generic.build(options).to_s
        end
      end

      class Real
        attr_reader :endpoint

        def initialize(options={})
          @local_root = ::File.expand_path(options[:local_root])

          @endpoint = options[:endpoint] || build_endpoint_from_options(options)
        end

        def local_root
          @local_root
        end

        def path_to(partial)
          ::File.join(@local_root, partial)
        end

        def copy_object(source_directory_name, source_object_name, target_directory_name, target_object_name, options={})
          source_path = path_to(::File.join(source_directory_name, source_object_name))
          target_path = path_to(::File.join(target_directory_name, target_object_name))
          ::FileUtils.mkdir_p(::File.dirname(target_path))
          ::FileUtils.copy_file(source_path, target_path)
        end

        private
        def build_endpoint_from_options(options)
          return unless options[:host]

          URI::Generic.build(options).to_s
        end
      end
    end
  end
end
