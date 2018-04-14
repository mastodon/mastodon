require 'set'
require 'sprockets/path_utils'
require 'sprockets/uri_utils'

module Sprockets
  # Internal: Related PathUtils helpers that also track all the file system
  # calls they make for caching purposes. All functions return a standard
  # return value and a Set of cache dependency URIs that can be used in the
  # future to see if the returned value should be invalidated from cache.
  #
  #     entries_with_dependencies("app/assets/javascripts")
  #     # => [
  #     #   ["application.js", "projects.js", "users.js", ...]
  #     #    #<Set: {"file-digest:/path/to/app/assets/javascripts"}>
  #     # ]
  #
  # The returned dependency set can be passed to resolve_dependencies(deps)
  # to check if the returned result is still fresh. In this case, entry always
  # returns a single path, but multiple calls should accumulate dependencies
  # into a single set thats saved off and checked later.
  #
  #     resolve_dependencies(deps)
  #     # => "\x01\x02\x03"
  #
  # Later, resolving the same set again will produce a different hash if
  # something on the file system has changed.
  #
  #     resolve_dependencies(deps)
  #     # => "\x03\x04\x05"
  #
  module PathDependencyUtils
    include PathUtils
    include URIUtils

    # Internal: List directory entries and return a set of dependencies that
    # would invalid the cached return result.
    #
    # See PathUtils#entries
    #
    # path - String directory path
    #
    # Returns an Array of entry names and a Set of dependency URIs.
    def entries_with_dependencies(path)
      return entries(path), file_digest_dependency_set(path)
    end

    # Internal: List directory filenames and associated Stats under a
    # directory.
    #
    # See PathUtils#stat_directory
    #
    # dir - A String directory
    #
    # Returns an Array of filenames and a Set of dependency URIs.
    def stat_directory_with_dependencies(dir)
      return stat_directory(dir).to_a, file_digest_dependency_set(dir)
    end

    # Internal: Returns a set of dependencies for a particular path.
    #
    # path - String directory path
    #
    # Returns a Set of dependency URIs.
    def file_digest_dependency_set(path)
      Set.new([build_file_digest_uri(path)])
    end

    # Internal: List directory filenames and associated Stats under an entire
    # directory tree.
    #
    # See PathUtils#stat_sorted_tree
    #
    # dir - A String directory
    #
    # Returns an Array of filenames and a Set of dependency URIs.
    def stat_sorted_tree_with_dependencies(dir)
      deps = Set.new([build_file_digest_uri(dir)])
      results = stat_sorted_tree(dir).map do |path, stat|
        deps << build_file_digest_uri(path) if stat.directory?
        [path, stat]
      end
      return results, deps
    end
  end
end
