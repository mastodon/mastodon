require 'active_support/core_ext/string'

module SimpleNavigation
  # Internal: Encapsulates the config file naming knowledge.
  class ConfigFile
    # Internal: Initializes a ConfigFile.
    #
    # context - The navigation context for this ConfigFile.
    def initialize(context)
      @prefix = prefix_for_context(context)
    end

    # Internal: Returns the name of the configuration file on disk.
    #
    # Based on the the initialization context the outcome may differ.
    #
    # Examples
    #
    #   ConfigFile.new.name           # => "navigation.rb"
    #   ConfigFile.new(:default).name # => "navigation.rb"
    #   ConfigFile.new(:other).name   # => "other_navigation.rb"
    #
    # Returns a String representing the name of the configuration file on disk.
    def name
      @name ||= "#{prefix}navigation.rb"
    end

    private

    attr_reader :prefix

    def prefix_for_context(context)
      context == :default ? '' : "#{context.to_s.underscore}_"
    end
  end
end
