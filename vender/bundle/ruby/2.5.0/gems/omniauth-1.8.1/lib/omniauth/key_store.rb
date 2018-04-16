require 'hashie/mash'

module OmniAuth
  # Generic helper hash that allows method access on deeply nested keys.
  class KeyStore < ::Hashie::Mash
    # Disables warnings on Hashie 3.5.0+ for overwritten keys
    def self.override_logging
      require 'hashie/version'
      return unless Gem::Version.new(Hashie::VERSION) >= Gem::Version.new('3.5.0')

      if respond_to?(:disable_warnings)
        disable_warnings
      else
        define_method(:log_built_in_message) { |*| }
        private :log_built_in_message
      end
    end

    # Disable on loading of the class
    override_logging
  end
end
