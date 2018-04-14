require 'sprockets/path_utils'
require 'sprockets/utils'

module Sprockets
  module Paths
    include PathUtils, Utils

    # Returns `Environment` root.
    #
    # All relative paths are expanded with root as its base. To be
    # useful set this to your applications root directory. (`Rails.root`)
    def root
      config[:root]
    end

    # Internal: Change Environment root.
    #
    # Only the initializer should change the root.
    def root=(path)
      self.config = hash_reassoc(config, :root) do
        File.expand_path(path)
      end
    end
    private :root=

    # Returns an `Array` of path `String`s.
    #
    # These paths will be used for asset logical path lookups.
    def paths
      config[:paths]
    end

    # Prepend a `path` to the `paths` list.
    #
    # Paths at the end of the `Array` have the least priority.
    def prepend_path(path)
      self.config = hash_reassoc(config, :paths) do |paths|
        path = File.expand_path(path, config[:root]).freeze
        paths.unshift(path)
      end
    end

    # Append a `path` to the `paths` list.
    #
    # Paths at the beginning of the `Array` have a higher priority.
    def append_path(path)
      self.config = hash_reassoc(config, :paths) do |paths|
        path = File.expand_path(path, config[:root]).freeze
        paths.push(path)
      end
    end

    # Clear all paths and start fresh.
    #
    # There is no mechanism for reordering paths, so its best to
    # completely wipe the paths list and reappend them in the order
    # you want.
    def clear_paths
      self.config = hash_reassoc(config, :paths) do |paths|
        paths.clear
      end
    end

    # Public: Iterate over every file under all load paths.
    #
    # Returns Enumerator if no block is given.
    def each_file
      return to_enum(__method__) unless block_given?

      paths.each do |root|
        stat_tree(root).each do |filename, stat|
          if stat.file?
            yield filename
          end
        end
      end

      nil
    end
  end
end
