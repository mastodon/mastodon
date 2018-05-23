require 'sprockets/eco_processor'

module Sprockets
  # Deprecated
  module EcoTemplate
    VERSION = EcoProcessor::VERSION

    def self.cache_key
      EcoProcessor.cache_key
    end

    def self.call(*args)
      Deprecation.new.warn "EcoTemplate is deprecated please use EcoProcessor instead"
      EcoProcessor.call(*args)
    end
  end
end
