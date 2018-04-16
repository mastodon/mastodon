module Fog
  module Storage
    class Local
      class Directories < Fog::Collection
        model Fog::Storage::Local::Directory

        def all
          data = if ::File.directory?(service.local_root)
            Dir.entries(service.local_root).select do |entry|
              entry[0...1] != '.' && ::File.directory?(service.path_to(entry))
            end.map do |entry|
              {:key => entry}
            end
          else
            []
          end
          load(data)
        end

        def get(key, options = {})
          create_directory(key, options) if ::File.directory?(service.path_to(key))
        end

        private
        def create_directory(key, options)
          options[:path] ? new(key: key + options[:path]) : new(key: key)
        end
      end
    end
  end
end
