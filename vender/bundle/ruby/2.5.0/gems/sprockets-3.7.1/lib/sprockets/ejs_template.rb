require 'sprockets/ejs_processor'

module Sprockets
  # Deprecated
  module EjsTemplate
    VERSION = EjsProcessor::VERSION

    def self.cache_key
      EjsProcessor.cache_key
    end

    def self.call(*args)
      Deprecation.new.warn "EjsTemplate is deprecated please use EjsProcessor instead"
      EjsProcessor.call(*args)
    end
  end
end
