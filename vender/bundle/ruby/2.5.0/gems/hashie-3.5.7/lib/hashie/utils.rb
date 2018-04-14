module Hashie
  # A collection of helper methods that can be used throughout the gem.
  module Utils
    # Describes a method by where it was defined.
    #
    # @param bound_method [Method] The method to describe.
    # @return [String]
    def self.method_information(bound_method)
      if bound_method.source_location
        "defined at #{bound_method.source_location.join(':')}"
      else
        "defined in #{bound_method.owner}"
      end
    end
  end
end
