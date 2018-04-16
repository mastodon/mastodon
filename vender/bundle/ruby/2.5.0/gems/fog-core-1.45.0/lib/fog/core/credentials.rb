require "yaml"

module Fog
  require "fog/core/deprecation"

  # Sets the global configuration up from a Hash rather than using background loading from a file
  #
  # @example
  #   Fog.credentials = {
  #     :default => {
  #       :example_url => "https://example.com/"
  #       :example_username => "bob",
  #       :example_password => "obo"
  #     },
  #     :production => {
  #       :example_username => "bob",
  #       :example_password => "obo"
  #     }
  #   }
  #
  # @return [Hash] The newly assigned credentials
  class << self
    attr_writer :credentials
  end

  # Assign a new credential to use from configuration file
  #
  # @param [String, Symbol] new_credential name of new credential to use
  # @return [Symbol] name of the new credential
  def self.credential=(new_credential)
    @credentials = nil
    @credential = new_credential && new_credential.to_sym
  end

  # This is the named credential from amongst the configuration file being used or +:default+
  #
  # @note This can be set using the +FOG_CREDENTIAL+ environment variable
  #
  # @return [Symbol] The credential to use in Fog
  def self.credential
    @credential ||= (ENV["FOG_CREDENTIAL"] && ENV["FOG_CREDENTIAL"].to_sym) || :default
  end

  # This returns the path to the configuration file being used globally to look for sets of
  # credentials
  #
  # @note This can be set using the +FOG_RC+ environment variable or defaults to +$HOME/.fog+
  #
  # @return [String] The path for configuration_file
  def self.credentials_path
    @credential_path ||= begin
      path = ENV["FOG_RC"] || (ENV["HOME"] && File.directory?(ENV["HOME"]) && "~/.fog")
      File.expand_path(path) if path
    rescue
      nil
    end
  end

  # @return [String] The new path for credentials file
  def self.credentials_path=(new_credentials_path)
    @credentials = nil
    @credential_path = new_credentials_path
  end

  # @return [Hash] The credentials pulled from the configuration file
  # @raise [LoadError] Configuration unavailable in configuration file
  def self.credentials
    @credentials ||= begin
      if credentials_path && File.exist?(credentials_path)
        credentials = Fog::Core::Utils.prepare_service_settings(YAML.load_file(credentials_path))
        (credentials && credentials[credential]) || Fog::Errors.missing_credentials
      else
        {}
      end
    end
  end

  # @deprecated Don't use!
  # @param [Object] key
  # @return [true] if key == :headers
  def self.symbolize_credential?(key)
    ![:headers].include?(key)
  end

  # @deprecated Use {Fog::Core::Utils.prepare_service_settings} instead
  def self.symbolize_credentials(hash)
    Fog::Core::Utils.prepare_service_settings(hash)
  end
end
