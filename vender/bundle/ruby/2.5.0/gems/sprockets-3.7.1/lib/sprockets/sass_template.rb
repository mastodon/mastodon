require 'sprockets/sass_processor'

module Sprockets
  # Deprecated
  class SassTemplate < SassProcessor
    def self.call(*args)
      Deprecation.new.warn "SassTemplate is deprecated please use SassProcessor instead"
      super
    end
  end

  # Deprecated
  class ScssTemplate < ScssProcessor
    def self.call(*args)
      Deprecation.new.warn "ScssTemplate is deprecated please use ScssProcessor instead"
      super
    end
  end
end
