module Doorkeeper
  class MissingConfiguration < StandardError
    # Defines a MissingConfiguration error for a missing Doorkeeper
    # configuration
    def initialize
      super('Configuration for doorkeeper missing. Do you have doorkeeper initializer?')
    end
  end

  def self.configure(&block)
    @config = Config::Builder.new(&block).build
    setup_orm_adapter
    setup_orm_models
    setup_application_owner if @config.enable_application_owner?
  end

  def self.configuration
    @config || (fail MissingConfiguration)
  end

  def self.setup_orm_adapter
    @orm_adapter = "doorkeeper/orm/#{configuration.orm}".classify.constantize
  rescue NameError => e
    fail e, "ORM adapter not found (#{configuration.orm})", <<-ERROR_MSG.squish
[doorkeeper] ORM adapter not found (#{configuration.orm}), or there was an error
trying to load it.

You probably need to add the related gem for this adapter to work with
doorkeeper.
      ERROR_MSG
  end

  def self.setup_orm_models
    @orm_adapter.initialize_models!
  end

  def self.setup_application_owner
    @orm_adapter.initialize_application_owner!
  end

  class Config
    class Builder
      def initialize(&block)
        @config = Config.new
        instance_eval(&block)
      end

      def build
        @config
      end

      # Provide support for an owner to be assigned to each registered
      # application (disabled by default)
      # Optional parameter confirmation: true (default false) if you want
      # to enforce ownership of a registered application
      #
      # @param opts [Hash] the options to confirm if an application owner
      #   is present
      # @option opts[Boolean] :confirmation (false)
      #   Set confirm_application_owner variable
      def enable_application_owner(opts = {})
        @config.instance_variable_set(:@enable_application_owner, true)
        confirm_application_owner if opts[:confirmation].present? && opts[:confirmation]
      end

      def confirm_application_owner
        @config.instance_variable_set(:@confirm_application_owner, true)
      end

      # Define default access token scopes for your provider
      #
      # @param scopes [Array] Default set of access (OAuth::Scopes.new)
      # token scopes
      def default_scopes(*scopes)
        @config.instance_variable_set(:@default_scopes, OAuth::Scopes.from_array(scopes))
      end

      # Define default access token scopes for your provider
      #
      # @param scopes [Array] Optional set of access (OAuth::Scopes.new)
      # token scopes
      def optional_scopes(*scopes)
        @config.instance_variable_set(:@optional_scopes, OAuth::Scopes.from_array(scopes))
      end

      # Change the way client credentials are retrieved from the request object.
      # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
      # falls back to the `:client_id` and `:client_secret` params from the
      # `params` object.
      #
      # @param methods [Array] Define client credentials
      def client_credentials(*methods)
        @config.instance_variable_set(:@client_credentials, methods)
      end

      # Change the way access token is authenticated from the request object.
      # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
      # falls back to the `:access_token` or `:bearer_token` params from the
      # `params` object.
      #
      # @param methods [Array] Define access token methods
      def access_token_methods(*methods)
        @config.instance_variable_set(:@access_token_methods, methods)
      end

      # Issue access tokens with refresh token (disabled by default)
      def use_refresh_token
        @config.instance_variable_set(:@refresh_token_enabled, true)
      end

      # Reuse access token for the same resource owner within an application
      # (disabled by default)
      # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
      def reuse_access_token
        @config.instance_variable_set(:@reuse_access_token, true)
      end
    end

    module Option
      # Defines configuration option
      #
      # When you call option, it defines two methods. One method will take place
      # in the +Config+ class and the other method will take place in the
      # +Builder+ class.
      #
      # The +name+ parameter will set both builder method and config attribute.
      # If the +:as+ option is defined, the builder method will be the specified
      # option while the config attribute will be the +name+ parameter.
      #
      # If you want to introduce another level of config DSL you can
      # define +builder_class+ parameter.
      # Builder should take a block as the initializer parameter and respond to function +build+
      # that returns the value of the config attribute.
      #
      # ==== Options
      #
      # * [:+as+] Set the builder method that goes inside +configure+ block
      # * [+:default+] The default value in case no option was set
      #
      # ==== Examples
      #
      #    option :name
      #    option :name, as: :set_name
      #    option :name, default: 'My Name'
      #    option :scopes builder_class: ScopesBuilder
      #
      def option(name, options = {})
        attribute = options[:as] || name
        attribute_builder = options[:builder_class]

        Builder.instance_eval do
          remove_method name if method_defined?(name)
          define_method name do |*args, &block|
            # TODO: is builder_class option being used?
            value = if attribute_builder
                      attribute_builder.new(&block).build
                    else
                      block ? block : args.first
                    end

            @config.instance_variable_set(:"@#{attribute}", value)
          end
        end

        define_method attribute do |*_args|
          if instance_variable_defined?(:"@#{attribute}")
            instance_variable_get(:"@#{attribute}")
          else
            options[:default]
          end
        end

        public attribute
      end
    end

    extend Option

    option :resource_owner_authenticator,
           as: :authenticate_resource_owner,
           default: (lambda do |_routes|
             ::Rails.logger.warn(I18n.t('doorkeeper.errors.messages.resource_owner_authenticator_not_configured'))
             nil
           end)

    option :admin_authenticator,
           as: :authenticate_admin,
           default: ->(_routes) {}

    option :resource_owner_from_credentials,
           default: (lambda do |_routes|
             ::Rails.logger.warn(I18n.t('doorkeeper.errors.messages.credential_flow_not_configured'))
             nil
           end)
    option :before_successful_strategy_response, default: ->(_request) {}
    option :after_successful_strategy_response,
           default: ->(_request, _response) {}
    option :skip_authorization,             default: ->(_routes) {}
    option :access_token_expires_in,        default: 7200
    option :custom_access_token_expires_in, default: ->(_app) { nil }
    option :authorization_code_expires_in,  default: 600
    option :orm,                            default: :active_record
    option :native_redirect_uri,            default: 'urn:ietf:wg:oauth:2.0:oob'
    option :active_record_options,          default: {}
    option :grant_flows,                    default: %w[authorization_code client_credentials]

    # Allows to forbid specific Application redirect URI's by custom rules.
    # Doesn't forbid any URI by default.
    #
    # @param forbid_redirect_uri [Proc] Block or any object respond to #call
    #
    option :forbid_redirect_uri,            default: ->(_uri) { false }

    # WWW-Authenticate Realm (default "Doorkeeper").
    #
    # @param realm [String] ("Doorkeeper") Authentication realm
    #
    option :realm,                          default: 'Doorkeeper'

    # Forces the usage of the HTTPS protocol in non-native redirect uris
    # (enabled by default in non-development environments). OAuth2
    # delegates security in communication to the HTTPS protocol so it is
    # wise to keep this enabled.
    #
    # @param [Boolean] boolean_or_block value for the parameter, true by default in
    # non-development environment
    #
    # @yield [uri] Conditional usage of SSL redirect uris.
    # @yieldparam [URI] Redirect URI
    # @yieldreturn [Boolean] Indicates necessity of usage of the HTTPS protocol
    #   in non-native redirect uris
    #
    option :force_ssl_in_redirect_uri,      default: !Rails.env.development?


    # Use a custom class for generating the access token.
    # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
    #
    # @param access_token_generator [String]
    #   the name of the access token generator class
    #
    option :access_token_generator,
           default: 'Doorkeeper::OAuth::Helpers::UniqueToken'

    # The controller Doorkeeper::ApplicationController inherits from.
    # Defaults to ActionController::Base.
    # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
    #
    # @param base_controller [String] the name of the base controller
    option :base_controller,
           default: 'ActionController::Base'

    attr_reader :reuse_access_token

    def refresh_token_enabled?
      @refresh_token_enabled ||= false
      !!@refresh_token_enabled
    end

    def enable_application_owner?
      @enable_application_owner ||= false
      !!@enable_application_owner
    end

    def confirm_application_owner?
      @confirm_application_owner ||= false
      !!@confirm_application_owner
    end

    def default_scopes
      @default_scopes ||= OAuth::Scopes.new
    end

    def optional_scopes
      @optional_scopes ||= OAuth::Scopes.new
    end

    def scopes
      @scopes ||= default_scopes + optional_scopes
    end

    def client_credentials_methods
      @client_credentials ||= %i[from_basic from_params]
    end

    def access_token_methods
      @access_token_methods ||= %i[from_bearer_authorization from_access_token_param from_bearer_param]
    end

    def authorization_response_types
      @authorization_response_types ||= calculate_authorization_response_types
    end

    def token_grant_types
      @token_grant_types ||= calculate_token_grant_types
    end

    private

    # Determines what values are acceptable for 'response_type' param in
    # authorization request endpoint, and return them as an array of strings.
    #
    def calculate_authorization_response_types
      types = []
      types << 'code'  if grant_flows.include? 'authorization_code'
      types << 'token' if grant_flows.include? 'implicit'
      types
    end

    # Determines what values are acceptable for 'grant_type' param token
    # request endpoint, and return them in array.
    #
    def calculate_token_grant_types
      types = grant_flows - ['implicit']
      types << 'refresh_token' if refresh_token_enabled?
      types
    end
  end
end
