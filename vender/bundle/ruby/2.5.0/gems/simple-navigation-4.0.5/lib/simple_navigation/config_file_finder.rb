require 'simple_navigation/config_file'

module SimpleNavigation
  # Internal: Encapsulates the configuration file finding logic.
  class ConfigFileFinder
    # Internal: Initializes a ConfigFileFinder.
    #
    # paths - an enumerable list of paths in which to look for configuration
    #         files.
    def initialize(paths)
      @paths = paths
    end

    # Internal: Searches a configuration file for the given context in the
    # initialization paths.
    #
    # context - The navigation context for which to look the configuration file.
    #
    # Returns a String representing the full path of the configuation file.
    # Raises StandardError if no file is found.
    def find(context)
      config_file_name = config_file_name_for_context(context)

      find_config_file(config_file_name) ||
      fail("Config file '#{config_file_name}' not found in " \
           "path(s) #{paths.join(', ')}!")
    end

    private

    attr_reader :paths

    def config_file_name_for_context(context)
      ConfigFile.new(context).name
    end

    def find_config_file(config_file_name)
      paths.map { |path| File.join(path, config_file_name) }
           .find { |full_path| File.exist?(full_path) }
    end
  end
end
