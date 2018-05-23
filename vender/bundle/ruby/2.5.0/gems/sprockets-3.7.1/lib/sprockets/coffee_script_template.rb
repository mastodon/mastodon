require 'sprockets/coffee_script_processor'

module Sprockets
  # Deprecated
  module CoffeeScriptTemplate
    VERSION = CoffeeScriptProcessor::VERSION

    def self.cache_key
      CoffeeScriptProcessor.cache_key
    end

    def self.call(*args)
      Deprecation.new.warn "CoffeeScriptTemplate is deprecated please use CoffeeScriptProcessor instead"
      CoffeeScriptProcessor.call(*args)
    end
  end
end
