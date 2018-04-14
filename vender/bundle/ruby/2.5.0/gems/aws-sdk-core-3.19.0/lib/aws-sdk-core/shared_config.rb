module Aws

  # @api private
  class SharedConfig

    # @return [String]
    attr_reader :credentials_path

    # @return [String]
    attr_reader :config_path

    # @return [String]
    attr_reader :profile_name

    # Constructs a new SharedConfig provider object. This will load the shared
    # credentials file, and optionally the shared configuration file, as ini
    # files which support profiles.
    #
    # By default, the shared credential file (the default path for which is
    # `~/.aws/credentials`) and the shared config file (the default path for
    # which is `~/.aws/config`) are loaded. However, if you set the
    # `ENV['AWS_SDK_CONFIG_OPT_OUT']` environment variable, only the shared
    # credential file will be loaded.
    #
    # The default profile name is 'default'. You can specify the profile name
    # with the `ENV['AWS_PROFILE']` environment variable or with the
    # `:profile_name` option.
    #
    # @param [Hash] options
    # @option options [String] :credentials_path Path to the shared credentials
    #   file. Defaults to "#{Dir.home}/.aws/credentials".
    # @option options [String] :config_path Path to the shared config file.
    #   Defaults to "#{Dir.home}/.aws/config".
    # @option options [String] :profile_name The credential/config profile name
    #   to use. If not specified, will check `ENV['AWS_PROFILE']` before using
    #   the fixed default value of 'default'.
    # @option options [Boolean] :config_enabled If true, loads the shared config
    #   file and enables new config values outside of the old shared credential
    #   spec.
    def initialize(options = {})
      @profile_name = determine_profile(options)
      @config_enabled = options[:config_enabled]
      @credentials_path = options[:credentials_path] ||
        determine_credentials_path
      @parsed_credentials = {}
      load_credentials_file if loadable?(@credentials_path)
      if @config_enabled
        @config_path = options[:config_path] || determine_config_path
        load_config_file if loadable?(@config_path)
      end
    end

    # @api private
    def fresh(options = {})
      @profile_name = nil
      @credentials_path = nil
      @config_path = nil
      @parsed_credentials = {}
      @parsed_config = nil
      @config_enabled = options[:config_enabled] ? true : false
      @profile_name = determine_profile(options)
      @credentials_path = options[:credentials_path] ||
        determine_credentials_path
      load_credentials_file if loadable?(@credentials_path)
      if @config_enabled
        @config_path = options[:config_path] || determine_config_path
        load_config_file if loadable?(@config_path)
      end
    end

    # @return [Boolean] Returns `true` if a credential file
    #   exists and has appropriate read permissions at {#path}.
    # @note This method does not indicate if the file found at {#path}
    #   will be parsable, only if it can be read.
    def loadable?(path)
      !path.nil? && File.exist?(path) && File.readable?(path)
    end

    # @return [Boolean] returns `true` if use of the shared config file is
    #   enabled.
    def config_enabled?
      @config_enabled ? true : false
    end

    # Sources static credentials from shared credential/config files.
    #
    # @param [Hash] opts
    # @option options [String] :profile the name of the configuration file from
    #   which credentials are being sourced.
    # @return [Aws::Credentials] credentials sourced from configuration values,
    #   or `nil` if no valid credentials were found.
    def credentials(opts = {})
      p = opts[:profile] || @profile_name
      validate_profile_exists(p) if credentials_present?
      if credentials = credentials_from_shared(p, opts)
        credentials
      elsif credentials = credentials_from_config(p, opts)
        credentials
      else
        nil
      end
    end

    # Attempts to assume a role from shared config or shared credentials file.
    # Will always attempt first to assume a role from the shared credentials
    # file, if present.
    def assume_role_credentials_from_config(opts = {})
      p = opts.delete(:profile) || @profile_name
      chain_config = opts.delete(:chain_config)
      credentials = assume_role_from_profile(@parsed_credentials, p, opts, chain_config)
      if @parsed_config
        credentials ||= assume_role_from_profile(@parsed_config, p, opts, chain_config)
      end
      credentials
    end

    def region(opts = {})
      p = opts[:profile] || @profile_name
      if @config_enabled
        if @parsed_credentials
          region = @parsed_credentials.fetch(p, {})["region"]
        end
        if @parsed_config
          region ||= @parsed_config.fetch(p, {})["region"]
        end
        region
      else
        nil
      end
    end

    private
    def credentials_present?
      (@parsed_credentials && !@parsed_credentials.empty?) ||
        (@parsed_config && !@parsed_config.empty?)
    end

    def assume_role_from_profile(cfg, profile, opts, chain_config)
      if cfg && prof_cfg = cfg[profile]
        opts[:source_profile] ||= prof_cfg["source_profile"]
        credential_source = opts.delete(:credential_source)
        credential_source ||= prof_cfg["credential_source"]
        if opts[:source_profile] && credential_source
          raise Errors::CredentialSourceConflictError.new(
            "Profile #{profile} has a source_profile, and "\
              "a credential_source. For assume role credentials, must "\
              "provide only source_profile or credential_source, not both."
          )
        elsif opts[:source_profile]
          opts[:credentials] = credentials(profile: opts[:source_profile])
          if opts[:credentials]
            opts[:role_session_name] ||= prof_cfg["role_session_name"]
            opts[:role_session_name] ||= "default_session"
            opts[:role_arn] ||= prof_cfg["role_arn"]
            opts[:external_id] ||= prof_cfg["external_id"]
            opts[:serial_number] ||= prof_cfg["mfa_serial"]
            opts[:profile] = opts.delete(:source_profile)
            AssumeRoleCredentials.new(opts)
          else
            raise Errors::NoSourceProfileError.new(
              "Profile #{profile} has a role_arn, and source_profile, but the"\
                " source_profile does not have credentials."
            )
          end
        elsif credential_source
          opts[:credentials] = credentials_from_source(
            credential_source,
            chain_config
          )
          if opts[:credentials]
            opts[:role_session_name] ||= prof_cfg["role_session_name"]
            opts[:role_session_name] ||= "default_session"
            opts[:role_arn] ||= prof_cfg["role_arn"]
            opts[:external_id] ||= prof_cfg["external_id"]
            opts[:serial_number] ||= prof_cfg["mfa_serial"]
            opts.delete(:source_profile) # Cleanup
            AssumeRoleCredentials.new(opts)
          else
            raise Errors::NoSourceCredentials.new(
              "Profile #{profile} could not get source credentials from"\
                " provider #{credential_source}"
            )
          end
        elsif prof_cfg["role_arn"]
          raise Errors::NoSourceProfileError.new(
            "Profile #{profile} has a role_arn, but no source_profile."
          )
        else
          nil
        end
      else
        nil
      end
    end

    def credentials_from_source(credential_source, config)
      case credential_source
      when "Ec2InstanceMetadata"
        InstanceProfileCredentials.new(
          retries: config ? config.instance_profile_credentials_retries : 0,
          http_open_timeout: config ? config.instance_profile_credentials_timeout : 1,
          http_read_timeout: config ? config.instance_profile_credentials_timeout : 1
        )
      when "EcsContainer"
        ECSCredentials.new
      else
        raise Errors::InvalidCredentialSourceError.new(
          "Unsupported credential_source: #{credential_source}"
        )
      end
    end

    def credentials_from_shared(profile, opts)
      if @parsed_credentials && prof_config = @parsed_credentials[profile]
        credentials_from_profile(prof_config)
      else
        nil
      end
    end

    def credentials_from_config(profile, opts)
      if @parsed_config && prof_config = @parsed_config[profile]
        credentials_from_profile(prof_config)
      else
        nil
      end
    end

    def credentials_from_profile(prof_config)
      creds = Credentials.new(
        prof_config['aws_access_key_id'],
        prof_config['aws_secret_access_key'],
        prof_config['aws_session_token']
      )
      if credentials_complete(creds)
        creds
      else
        nil
      end
    end

    def credentials_complete(creds)
      creds.set?
    end

    def load_credentials_file
      @parsed_credentials = IniParser.ini_parse(
        File.read(@credentials_path)
      )
    end

    def load_config_file
      @parsed_config = IniParser.ini_parse(File.read(@config_path))
    end

    def determine_credentials_path
      default_shared_config_path('credentials')
    end

    def determine_config_path
      default_shared_config_path('config')
    end

    def default_shared_config_path(file)
      File.join(Dir.home, '.aws', file)
    rescue ArgumentError
      # Dir.home raises ArgumentError when ENV['home'] is not set
      nil
    end

    def validate_profile_exists(profile)
      unless (@parsed_credentials && @parsed_credentials[profile]) ||
          (@parsed_config && @parsed_config[profile])
        msg = "Profile `#{profile}' not found in #{@credentials_path}"
        msg << " or #{@config_path}" if @config_path
        raise Errors::NoSuchProfileError.new(msg)
      end
    end

    def determine_profile(options)
      ret = options[:profile_name]
      ret ||= ENV["AWS_PROFILE"]
      ret ||= "default"
      ret
    end

  end
end
