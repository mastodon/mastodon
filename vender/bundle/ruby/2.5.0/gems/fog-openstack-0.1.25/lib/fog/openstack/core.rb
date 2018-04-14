module Fog
  module OpenStack
    module Core
      attr_accessor :auth_token
      attr_reader :unscoped_token
      attr_reader :openstack_cache_ttl
      attr_reader :auth_token_expiration
      attr_reader :current_user
      attr_reader :current_user_id
      attr_reader :current_tenant
      attr_reader :openstack_domain_name
      attr_reader :openstack_user_domain
      attr_reader :openstack_project_domain
      attr_reader :openstack_domain_id
      attr_reader :openstack_user_domain_id
      attr_reader :openstack_project_id
      attr_reader :openstack_project_domain_id
      attr_reader :openstack_identity_prefix

      # fallback
      def self.not_found_class
        Fog::Compute::OpenStack::NotFound
      end

      def initialize_identity(options)
        # Create @openstack_* instance variables from all :openstack_* options
        options.select { |x| x.to_s.start_with? 'openstack' }.each do |openstack_param, value|
          instance_variable_set "@#{openstack_param}".to_sym, value
        end

        @auth_token ||= options[:openstack_auth_token]
        @openstack_identity_public_endpoint = options[:openstack_identity_endpoint]

        @openstack_auth_uri = URI.parse(options[:openstack_auth_url])
        @openstack_must_reauthenticate = false
        @openstack_endpoint_type = options[:openstack_endpoint_type] || 'publicURL'

        @openstack_cache_ttl = options[:openstack_cache_ttl] || 0

        if @auth_token
          @openstack_can_reauthenticate = false
        else
          missing_credentials = []

          missing_credentials << :openstack_api_key unless @openstack_api_key
          unless @openstack_username || @openstack_userid
            missing_credentials << 'openstack_username or openstack_userid'
          end
          raise ArgumentError, "Missing required arguments: #{missing_credentials.join(', ')}" unless missing_credentials.empty?
          @openstack_can_reauthenticate = true
        end

        @current_user    = options[:current_user]
        @current_user_id = options[:current_user_id]
        @current_tenant  = options[:current_tenant]
      end

      def credentials
        options = {
          :provider                    => 'openstack',
          :openstack_auth_url          => @openstack_auth_uri.to_s,
          :openstack_auth_token        => @auth_token,
          :openstack_identity_endpoint => @openstack_identity_public_endpoint,
          :current_user                => @current_user,
          :current_user_id             => @current_user_id,
          :current_tenant              => @current_tenant,
          :unscoped_token              => @unscoped_token
        }
        openstack_options.merge options
      end

      def reload
        @connection.reset
      end

      private

      def request(params, parse_json = true)
        retried = false
        begin
          response = @connection.request(params.merge(
                                           :headers => headers(params.delete(:headers)),
                                           :path    => "#{@path}/#{params[:path]}"
          ))
        rescue Excon::Errors::Unauthorized => error
          # token expiration and token renewal possible
          if error.response.body != 'Bad username or password' && @openstack_can_reauthenticate && !retried
            @openstack_must_reauthenticate = true
            authenticate
            set_api_path
            retried = true
            retry
          # bad credentials or token renewal not possible
          else
            raise error
          end
        rescue Excon::Errors::HTTPStatusError => error
          raise case error
                when Excon::Errors::NotFound
                  self.class.not_found_class.slurp(error)
                else
                  error
                end
        end

        if !response.body.empty? && response.get_header('Content-Type').match('application/json')
          # TODO: remove parse_json in favor of :raw_body
          response.body = Fog::JSON.decode(response.body) if parse_json && !params[:raw_body]
        end

        response
      end

      def set_api_path
        # if the service supports multiple versions, do the selection here
      end

      def set_microversion
        @microversion_key          ||= 'Openstack-API-Version'.freeze
        @microversion_service_type ||= @openstack_service_type.first

        @microversion = Fog::OpenStack.get_supported_microversion(
          @supported_versions,
          @openstack_management_uri,
          @auth_token,
          @connection_options
        ).to_s

        # choose minimum out of reported and supported version
        if microversion_newer_than?(@supported_microversion)
          @microversion = @supported_microversion
        end

        # choose minimum out of set and wished version
        if @fixed_microversion && microversion_newer_than?(@fixed_microversion)
          @microversion = @fixed_microversion
        elsif @fixed_microversion && @microversion != @fixed_microversion
          Fog::Logger.warning("Microversion #{@fixed_microversion} not supported")
        end
      end

      def microversion_newer_than?(version)
        Gem::Version.new(version) < Gem::Version.new(@microversion)
      end

      def headers(additional_headers)
        additional_headers ||= {}
        unless @microversion.nil? || @microversion.empty?
          microversion_value = if @microversion_key == 'Openstack-API-Version'
                                 "#{@microversion_service_type} #{@microversion}"
                               else
                                 @microversion
                               end
          microversion_header = {@microversion_key => microversion_value}
          additional_headers.merge!(microversion_header)
        end

        {
          'Content-Type' => 'application/json',
          'Accept'       => 'application/json',
          'X-Auth-Token' => @auth_token
        }.merge!(additional_headers)
      end

      def openstack_options
        options = {}
        # Create a hash of (:openstack_*, value) of all the @openstack_* instance variables
        instance_variables.select { |x| x.to_s.start_with? '@openstack' }.each do |openstack_param|
          option_name = openstack_param.to_s[1..-1]
          options[option_name.to_sym] = instance_variable_get openstack_param
        end
        options
      end

      def authenticate
        if !@openstack_management_url || @openstack_must_reauthenticate

          options = openstack_options

          options[:openstack_auth_token] = @openstack_must_reauthenticate ? nil : @openstack_auth_token

          credentials = Fog::OpenStack.authenticate(options, @connection_options)

          @current_user = credentials[:user]
          @current_user_id = credentials[:current_user_id]
          @current_tenant = credentials[:tenant]

          @openstack_must_reauthenticate = false
          @auth_token = credentials[:token]
          @openstack_management_url = credentials[:server_management_url]
          @unscoped_token = credentials[:unscoped_token]
        else
          @auth_token = @openstack_auth_token
        end
        @openstack_management_uri = URI.parse(@openstack_management_url)

        @host   = @openstack_management_uri.host
        @path   = @openstack_management_uri.path
        @path.sub!(%r{/$}, '')
        @port   = @openstack_management_uri.port
        @scheme = @openstack_management_uri.scheme

        # Not all implementations have identity service in the catalog
        if @openstack_identity_public_endpoint || @openstack_management_url
          @identity_connection = Fog::Core::Connection.new(
            @openstack_identity_public_endpoint || @openstack_management_url,
            false, @connection_options
          )
        end

        # both need to be set in service's initialize for microversions to work
        set_microversion if @supported_microversion && @supported_versions

        true
      end
    end
  end
end
