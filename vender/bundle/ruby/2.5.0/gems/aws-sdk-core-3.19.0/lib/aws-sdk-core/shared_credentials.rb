require_relative 'ini_parser'

module Aws
  class SharedCredentials

    include CredentialProvider

    # @api private
    KEY_MAP = {
      'aws_access_key_id' => 'access_key_id',
      'aws_secret_access_key' => 'secret_access_key',
      'aws_session_token' => 'session_token',
    }

    # Constructs a new SharedCredentials object. This will load AWS access
    # credentials from an ini file, which supports profiles. The default
    # profile name is 'default'. You can specify the profile name with the
    # `ENV['AWS_PROFILE']` or with the `:profile_name` option.
    #
    # @option [String] :path Path to the shared file.  Defaults
    #   to "#{Dir.home}/.aws/credentials".
    #
    # @option [String] :profile_name Defaults to 'default' or
    #   `ENV['AWS_PROFILE']`.
    #
    def initialize(options = {})
      shared_config = Aws.shared_config
      @path = options[:path]
      @path ||= shared_config.credentials_path
      @profile_name = options[:profile_name]
      @profile_name ||= ENV['AWS_PROFILE']
      @profile_name ||= shared_config.profile_name
      if @path && @path == shared_config.credentials_path
        @credentials = shared_config.credentials(profile: @profile_name)
      else
        config = SharedConfig.new(
          credentials_path: @path,
          profile_name: @profile_name
        )
        @credentials = config.credentials(profile: @profile_name)
      end
    end

    # @return [String]
    attr_reader :path

    # @return [String]
    attr_reader :profile_name

    # @return [Credentials]
    attr_reader :credentials

    # @api private
    def inspect
      parts = [
        self.class.name,
        "profile_name=#{profile_name.inspect}",
        "path=#{path.inspect}",
      ]
      "#<#{parts.join(' ')}>"
    end

    # @deprecated This method is no longer used.
    # @return [Boolean] Returns `true` if a credential file
    #   exists and has appropriate read permissions at {#path}.
    # @note This method does not indicate if the file found at {#path}
    #   will be parsable, only if it can be read.
    def loadable?
      !path.nil? && File.exist?(path) && File.readable?(path)
    end

  end
end
