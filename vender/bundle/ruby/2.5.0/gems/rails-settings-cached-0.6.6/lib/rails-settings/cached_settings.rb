module RailsSettings
  class CachedSettings < Base
    def self.inherited(subclass)
      Kernel.warn 'DEPRECATION WARNING: RailsSettings::CachedSettings is deprecated ' \
                  'and it will removed in 0.7.0. ' \
                  'Please use RailsSettings::Base instead.'
      super(subclass)
    end
  end
end
