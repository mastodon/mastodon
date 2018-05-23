require_relative '../explicit_require'

module Bootsnap
  module LoadPathCache
    module PathScanner
      # Glob pattern to find requirable files and subdirectories in given path.
      # It expands to:
      #
      #   * `/*{.rb,.so,/}` - It matches requirable files, directories and
      #     symlinks to directories at given path.
      #   * `/*/**/*{.rb,.so,/}` - It matches requirable files and
      #     subdirectories in any (even symlinked) directory at given path at
      #     any directory tree depth.
      #
      REQUIRABLES_AND_DIRS = "/{,*/**/}*{#{DOT_RB},#{DL_EXTENSIONS.join(',')},/}"
      NORMALIZE_NATIVE_EXTENSIONS = !DL_EXTENSIONS.include?(LoadPathCache::DOT_SO)
      ALTERNATIVE_NATIVE_EXTENSIONS_PATTERN = /\.(o|bundle|dylib)\z/
      BUNDLE_PATH = Bootsnap.bundler? ?
        (Bundler.bundle_path.cleanpath.to_s << LoadPathCache::SLASH).freeze : ''.freeze

      def self.call(path)
        path = path.to_s

        relative_slice = (path.size + 1)..-1
        # If the bundle path is a descendent of this path, we do additional
        # checks to prevent recursing into the bundle path as we recurse
        # through this path. We don't want to scan the bundle path because
        # anything useful in it will be present on other load path items.
        #
        # This can happen if, for example, the user adds '.' to the load path,
        # and the bundle path is '.bundle'.
        contains_bundle_path = BUNDLE_PATH.start_with?(path)

        dirs = []
        requirables = []

        Dir.glob(path + REQUIRABLES_AND_DIRS).each do |absolute_path|
          next if contains_bundle_path && absolute_path.start_with?(BUNDLE_PATH)
          relative_path = absolute_path.slice!(relative_slice)

          if relative_path.end_with?('/')
            dirs << relative_path[0..-2]
          else
            requirables << relative_path
          end
        end

        [requirables, dirs]
      end
    end
  end
end
