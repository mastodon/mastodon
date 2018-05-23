# frozen_string_literal: true

require 'rails'
require 'active_support/core_ext/numeric/time'
require 'active_support/dependencies'
require 'orm_adapter'
require 'set'
require 'securerandom'
require 'responders'

module Devise
  autoload :Delegator,          'devise/delegator'
  autoload :Encryptor,          'devise/encryptor'
  autoload :FailureApp,         'devise/failure_app'
  autoload :OmniAuth,           'devise/omniauth'
  autoload :ParameterFilter,    'devise/parameter_filter'
  autoload :ParameterSanitizer, 'devise/parameter_sanitizer'
  autoload :TestHelpers,        'devise/test_helpers'
  autoload :TimeInflector,      'devise/time_inflector'
  autoload :TokenGenerator,     'devise/token_generator'
  autoload :SecretKeyFinder,    'devise/secret_key_finder'

  module Controllers
    autoload :Helpers,        'devise/controllers/helpers'
    autoload :Rememberable,   'devise/controllers/rememberable'
    autoload :ScopedViews,    'devise/controllers/scoped_views'
    autoload :SignInOut,      'devise/controllers/sign_in_out'
    autoload :StoreLocation,  'devise/controllers/store_location'
    autoload :UrlHelpers,     'devise/controllers/url_helpers'
  end

  module Hooks
    autoload :Proxy, 'devise/hooks/proxy'
  end

  module Mailers
    autoload :Helpers, 'devise/mailers/helpers'
  end

  module Strategies
    autoload :Base,            'devise/strategies/base'
    autoload :Authenticatable, 'devise/strategies/authenticatable'
  end

  module Test
    autoload :ControllerHelpers,  'devise/test/controller_helpers'
    autoload :IntegrationHelpers, 'devise/test/integration_helpers'
  end

  # Constants which holds devise configuration for extensions. Those should
  # not be modified by the "end user" (this is why they are constants).
  ALL         = []
  CONTROLLERS = {}
  ROUTES      = {}
  STRATEGIES  = {}
  URL_HELPERS = {}

  # Strategies that do not require user input.
  NO_INPUT = []

  # True values used to check params
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

  # Secret key used by the key generator
  mattr_accessor :secret_key
  @@secret_key = nil

  # Custom domain or key for cookies. Not set by default
  mattr_accessor :rememberable_options
  @@rememberable_options = {}

  # The number of times to hash the password.
  mattr_accessor :stretches
  @@stretches = 11

  # The default key used when authenticating over http auth.
  mattr_accessor :http_authentication_key
  @@http_authentication_key = nil

  # Keys used when authenticating a user.
  mattr_accessor :authentication_keys
  @@authentication_keys = [:email]

  # Request keys used when authenticating a user.
  mattr_accessor :request_keys
  @@request_keys = []

  # Keys that should be case-insensitive.
  mattr_accessor :case_insensitive_keys
  @@case_insensitive_keys = [:email]

  # Keys that should have whitespace stripped.
  mattr_accessor :strip_whitespace_keys
  @@strip_whitespace_keys = [:email]

  # If http authentication is enabled by default.
  mattr_accessor :http_authenticatable
  @@http_authenticatable = false

  # If http headers should be returned for ajax requests. True by default.
  mattr_accessor :http_authenticatable_on_xhr
  @@http_authenticatable_on_xhr = true

  # If params authenticatable is enabled by default.
  mattr_accessor :params_authenticatable
  @@params_authenticatable = true

  # The realm used in Http Basic Authentication.
  mattr_accessor :http_authentication_realm
  @@http_authentication_realm = "Application"

  # Email regex used to validate email formats. It asserts that there are no
  # @ symbols or whitespaces in either the localpart or the domain, and that
  # there is a single @ symbol separating the localpart and the domain.
  mattr_accessor :email_regexp
  @@email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # Range validation for password length
  mattr_accessor :password_length
  @@password_length = 6..128

  # The time the user will be remembered without asking for credentials again.
  mattr_accessor :remember_for
  @@remember_for = 2.weeks

  # If true, extends the user's remember period when remembered via cookie.
  mattr_accessor :extend_remember_period
  @@extend_remember_period = false

  # If true, all the remember me tokens are going to be invalidated when the user signs out.
  mattr_accessor :expire_all_remember_me_on_sign_out
  @@expire_all_remember_me_on_sign_out = true

  # Time interval you can access your account before confirming your account.
  # nil - allows unconfirmed access for unlimited time
  mattr_accessor :allow_unconfirmed_access_for
  @@allow_unconfirmed_access_for = 0.days

  # Time interval the confirmation token is valid. nil = unlimited
  mattr_accessor :confirm_within
  @@confirm_within = nil

  # Defines which key will be used when confirming an account.
  mattr_accessor :confirmation_keys
  @@confirmation_keys = [:email]

  # Defines if email should be reconfirmable.
  mattr_accessor :reconfirmable
  @@reconfirmable = true

  # Time interval to timeout the user session without activity.
  mattr_accessor :timeout_in
  @@timeout_in = 30.minutes

  # Used to hash the password. Please generate one with rails secret.
  mattr_accessor :pepper
  @@pepper = nil

  # Used to send notification to the original user email when their email is changed.
  mattr_accessor :send_email_changed_notification
  @@send_email_changed_notification = false

  # Used to enable sending notification to user when their password is changed.
  mattr_accessor :send_password_change_notification
  @@send_password_change_notification = false

  # Scoped views. Since it relies on fallbacks to render default views, it's
  # turned off by default.
  mattr_accessor :scoped_views
  @@scoped_views = false

  # Defines which strategy can be used to lock an account.
  # Values: :failed_attempts, :none
  mattr_accessor :lock_strategy
  @@lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  mattr_accessor :unlock_keys
  @@unlock_keys = [:email]

  # Defines which strategy can be used to unlock an account.
  # Values: :email, :time, :both
  mattr_accessor :unlock_strategy
  @@unlock_strategy = :both

  # Number of authentication tries before locking an account
  mattr_accessor :maximum_attempts
  @@maximum_attempts = 20

  # Time interval to unlock the account if :time is defined as unlock_strategy.
  mattr_accessor :unlock_in
  @@unlock_in = 1.hour

  # Defines which key will be used when recovering the password for an account
  mattr_accessor :reset_password_keys
  @@reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key
  mattr_accessor :reset_password_within
  @@reset_password_within = 6.hours

  # When set to false, resetting a password does not automatically sign in a user
  mattr_accessor :sign_in_after_reset_password
  @@sign_in_after_reset_password = true

  # The default scope which is used by warden.
  mattr_accessor :default_scope
  @@default_scope = nil

  # Address which sends Devise e-mails.
  mattr_accessor :mailer_sender
  @@mailer_sender = nil

  # Skip session storage for the following strategies
  mattr_accessor :skip_session_storage
  @@skip_session_storage = [:http_auth]

  # Which formats should be treated as navigational.
  mattr_accessor :navigational_formats
  @@navigational_formats = ["*/*", :html]

  # When set to true, signing out a user signs out all other scopes.
  mattr_accessor :sign_out_all_scopes
  @@sign_out_all_scopes = true

  # The default method used while signing out
  mattr_accessor :sign_out_via
  @@sign_out_via = :delete

  # The parent controller all Devise controllers inherits from.
  # Defaults to ApplicationController. This should be set early
  # in the initialization process and should be set to a string.
  mattr_accessor :parent_controller
  @@parent_controller = "ApplicationController"

  # The parent mailer all Devise mailers inherit from.
  # Defaults to ActionMailer::Base. This should be set early
  # in the initialization process and should be set to a string.
  mattr_accessor :parent_mailer
  @@parent_mailer = "ActionMailer::Base"

  # The router Devise should use to generate routes. Defaults
  # to :main_app. Should be overridden by engines in order
  # to provide custom routes.
  mattr_accessor :router_name
  @@router_name = nil

  # Set the OmniAuth path prefix so it can be overridden when
  # Devise is used in a mountable engine
  mattr_accessor :omniauth_path_prefix
  @@omniauth_path_prefix = nil

  # Set if we should clean up the CSRF Token on authentication
  mattr_accessor :clean_up_csrf_token_on_authentication
  @@clean_up_csrf_token_on_authentication = true

  # When false, Devise will not attempt to reload routes on eager load.
  # This can reduce the time taken to boot the app but if your application
  # requires the Devise mappings to be loaded during boot time the application
  # won't boot properly.
  mattr_accessor :reload_routes
  @@reload_routes = true

  # PRIVATE CONFIGURATION

  # Store scopes mappings.
  mattr_reader :mappings
  @@mappings = {}

  # OmniAuth configurations.
  mattr_reader :omniauth_configs
  @@omniauth_configs = {}

  # Define a set of modules that are called when a mapping is added.
  mattr_reader :helpers
  @@helpers = Set.new
  @@helpers << Devise::Controllers::Helpers

  # Private methods to interface with Warden.
  mattr_accessor :warden_config
  @@warden_config = nil
  @@warden_config_blocks = []

  # When true, enter in paranoid mode to avoid user enumeration.
  mattr_accessor :paranoid
  @@paranoid = false

  # When true, warn user if they just used next-to-last attempt of authentication
  mattr_accessor :last_attempt_warning
  @@last_attempt_warning = true

  # Stores the token generator
  mattr_accessor :token_generator
  @@token_generator = nil

  def self.rails51? # :nodoc:
    Rails.gem_version >= Gem::Version.new("5.1.x")
  end

  def self.activerecord51? # :nodoc:
    defined?(ActiveRecord) && ActiveRecord.gem_version >= Gem::Version.new("5.1.x")
  end

  # Default way to set up Devise. Run rails generate devise_install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end

  class Getter
    def initialize(name)
      @name = name
    end

    def get
      ActiveSupport::Dependencies.constantize(@name)
    end
  end

  def self.ref(arg)
    ActiveSupport::Dependencies.reference(arg)
    Getter.new(arg)
  end

  def self.available_router_name
    router_name || :main_app
  end

  def self.omniauth_providers
    omniauth_configs.keys
  end

  # Get the mailer class from the mailer reference object.
  def self.mailer
    @@mailer_ref.get
  end

  # Set the mailer reference object to access the mailer.
  def self.mailer=(class_name)
    @@mailer_ref = ref(class_name)
  end
  self.mailer = "Devise::Mailer"

  # Small method that adds a mapping to Devise.
  def self.add_mapping(resource, options)
    mapping = Devise::Mapping.new(resource, options)
    @@mappings[mapping.name] = mapping
    @@default_scope ||= mapping.name
    @@helpers.each { |h| h.define_helpers(mapping) }
    mapping
  end

  # Register available devise modules. For the standard modules that Devise provides, this method is
  # called from lib/devise/modules.rb. Third-party modules need to be added explicitly using this method.
  #
  # Note that adding a module using this method does not cause it to be used in the authentication
  # process. That requires that the module be listed in the arguments passed to the 'devise' method
  # in the model class definition.
  #
  # == Options:
  #
  #   +model+      - String representing the load path to a custom *model* for this module (to autoload.)
  #   +controller+ - Symbol representing the name of an existing or custom *controller* for this module.
  #   +route+      - Symbol representing the named *route* helper for this module.
  #   +strategy+   - Symbol representing if this module got a custom *strategy*.
  #   +insert_at+  - Integer representing the order in which this module's model will be included
  #
  # All values, except :model, accept also a boolean and will have the same name as the given module
  # name.
  #
  # == Examples:
  #
  #   Devise.add_module(:party_module)
  #   Devise.add_module(:party_module, strategy: true, controller: :sessions)
  #   Devise.add_module(:party_module, model: 'party_module/model')
  #   Devise.add_module(:party_module, insert_at: 0)
  #
  def self.add_module(module_name, options = {})
    options.assert_valid_keys(:strategy, :model, :controller, :route, :no_input, :insert_at)

    ALL.insert (options[:insert_at] || -1), module_name

    if strategy = options[:strategy]
      strategy = (strategy == true ? module_name : strategy)
      STRATEGIES[module_name] = strategy
    end

    if controller = options[:controller]
      controller = (controller == true ? module_name : controller)
      CONTROLLERS[module_name] = controller
    end

    NO_INPUT << strategy if options[:no_input]

    if route = options[:route]
      case route
      when TrueClass
        key, value = module_name, []
      when Symbol
        key, value = route, []
      when Hash
        key, value = route.keys.first, route.values.flatten
      else
        raise ArgumentError, ":route should be true, a Symbol or a Hash"
      end

      URL_HELPERS[key] ||= []
      URL_HELPERS[key].concat(value)
      URL_HELPERS[key].uniq!

      ROUTES[module_name] = key
    end

    if options[:model]
      path = (options[:model] == true ? "devise/models/#{module_name}" : options[:model])
      camelized = ActiveSupport::Inflector.camelize(module_name.to_s)
      Devise::Models.send(:autoload, camelized.to_sym, path)
    end

    Devise::Mapping.add_module module_name
  end

  # Sets warden configuration using a block that will be invoked on warden
  # initialization.
  #
  #  Devise.setup do |config|
  #    config.allow_unconfirmed_access_for = 2.days
  #
  #    config.warden do |manager|
  #      # Configure warden to use other strategies, like oauth.
  #      manager.oauth(:twitter)
  #    end
  #  end
  def self.warden(&block)
    @@warden_config_blocks << block
  end

  # Specify an OmniAuth provider.
  #
  #   config.omniauth :github, APP_ID, APP_SECRET
  #
  def self.omniauth(provider, *args)
    config = Devise::OmniAuth::Config.new(provider, args)
    @@omniauth_configs[config.strategy_name.to_sym] = config
  end

  # Include helpers in the given scope to AC and AV.
  def self.include_helpers(scope)
    ActiveSupport.on_load(:action_controller) do
      include scope::Helpers if defined?(scope::Helpers)
      include scope::UrlHelpers
    end

    ActiveSupport.on_load(:action_view) do
      include scope::UrlHelpers
    end
  end

  # Regenerates url helpers considering Devise.mapping
  def self.regenerate_helpers!
    Devise::Controllers::UrlHelpers.remove_helpers!
    Devise::Controllers::UrlHelpers.generate_helpers!
  end

  # A method used internally to complete the setup of warden manager after routes are loaded.
  # See lib/devise/rails/routes.rb - ActionDispatch::Routing::RouteSet#finalize_with_devise!
  def self.configure_warden! #:nodoc:
    @@warden_configured ||= begin
      warden_config.failure_app   = Devise::Delegator.new
      warden_config.default_scope = Devise.default_scope
      warden_config.intercept_401 = false

      Devise.mappings.each_value do |mapping|
        warden_config.scope_defaults mapping.name, strategies: mapping.strategies

        warden_config.serialize_into_session(mapping.name) do |record|
          mapping.to.serialize_into_session(record)
        end

        warden_config.serialize_from_session(mapping.name) do |args|
          mapping.to.serialize_from_session(*args)
        end
      end

      @@warden_config_blocks.map { |block| block.call Devise.warden_config }
      true
    end
  end

  # Generate a friendly string randomly to be used as token.
  # By default, length is 20 characters.
  def self.friendly_token(length = 20)
    # To calculate real characters, we must perform this operation.
    # See SecureRandom.urlsafe_base64
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end

  # constant-time comparison algorithm to prevent timing attacks
  def self.secure_compare(a, b)
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end

require 'warden'
require 'devise/mapping'
require 'devise/models'
require 'devise/modules'
require 'devise/rails'
