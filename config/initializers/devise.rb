# frozen_string_literal: true

require 'devise/strategies/authenticatable'

Warden::Manager.after_set_user except: :fetch do |user, warden|
  session_id = warden.cookies.signed['_session_id'] || warden.raw_session['auth_id']
  session_id = user.activate_session(warden.request) unless user.session_activations.active?(session_id)

  warden.cookies.signed['_session_id'] = {
    value: session_id,
    expires: 1.year.from_now,
    httponly: true,
    same_site: :lax,
  }
end

Warden::Manager.after_fetch do |user, warden|
  session_id = warden.cookies.signed['_session_id'] || warden.raw_session['auth_id']

  if session_id && (session = user.session_activations.find_by(session_id: session_id))
    session.update(ip: warden.request.remote_ip) if session.ip != warden.request.remote_ip

    warden.cookies.signed['_session_id'] = {
      value: session_id,
      expires: 1.year.from_now,
      httponly: true,
      same_site: :lax,
    }
  else
    warden.logout
    throw :warden, message: :unauthenticated
  end
end

Warden::Manager.before_logout do |_, warden|
  SessionActivation.deactivate warden.cookies.signed['_session_id']
  warden.cookies.delete('_session_id')
end

module Devise
  mattr_accessor :pam_authentication
  @@pam_authentication = false
  mattr_accessor :pam_controlled_service
  @@pam_controlled_service = nil

  mattr_accessor :check_at_sign
  @@check_at_sign = false

  mattr_accessor :ldap_authentication
  @@ldap_authentication = false
  mattr_accessor :ldap_host
  @@ldap_host = nil
  mattr_accessor :ldap_port
  @@ldap_port = nil
  mattr_accessor :ldap_method
  @@ldap_method = nil
  mattr_accessor :ldap_base
  @@ldap_base = nil
  mattr_accessor :ldap_uid
  @@ldap_uid = nil
  mattr_accessor :ldap_mail
  @@ldap_mail = nil
  mattr_accessor :ldap_bind_dn
  @@ldap_bind_dn = nil
  mattr_accessor :ldap_password
  @@ldap_password = nil
  mattr_accessor :ldap_tls_no_verify
  @@ldap_tls_no_verify = false
  mattr_accessor :ldap_search_filter
  @@ldap_search_filter = nil
  mattr_accessor :ldap_uid_conversion_enabled
  @@ldap_uid_conversion_enabled = false
  mattr_accessor :ldap_uid_conversion_search
  @@ldap_uid_conversion_search = nil
  mattr_accessor :ldap_uid_conversion_replace
  @@ldap_uid_conversion_replace = nil

  module Strategies
    class PamAuthenticatable
      def valid?
        super && ::Devise.pam_authentication
      end
    end

    class SessionActivationRememberable < Authenticatable
      def valid?
        @session_cookie = nil
        session_cookie.present?
      end

      def authenticate!
        resource = SessionActivation.find_by(session_id: session_cookie)&.user

        unless resource
          cookies.delete('_session_id')
          return pass
        end

        if validate(resource)
          success!(resource)
        end
      end

      private

      def session_cookie
        @session_cookie ||= cookies.signed['_session_id']
      end
    end
  end
end

Warden::Strategies.add(:session_activation_rememberable, Devise::Strategies::SessionActivationRememberable)

Devise.setup do |config|
  config.warden do |manager|
    manager.default_strategies(scope: :user).unshift :two_factor_ldap_authenticatable if Devise.ldap_authentication
    manager.default_strategies(scope: :user).unshift :two_factor_pam_authenticatable  if Devise.pam_authentication
    manager.default_strategies(scope: :user).unshift :session_activation_rememberable
    manager.default_strategies(scope: :user).unshift :two_factor_authenticatable
    manager.default_strategies(scope: :user).unshift :two_factor_backupable
  end

  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  # Devise will use the `secret_key_base` on Rails 4+ applications as its `secret_key`
  # by default. You can change it below and use your own secret key.
  # config.secret_key = '2f86974c4dd7735170fd70fbf399f7a477ffd635ef240d07a22cf4bd7cd13dbae17c4383a2996d0c1e79a991ec18a91a17424c53e4771adb75a8b21904bd1403'

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  # config.mailer_sender = ENV['SMTP_FROM_ADDRESS'] || 'notifications@localhost'

  # Configure the class responsible to send e-mails.
  config.mailer = 'UserMailer'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  # config.authentication_keys = [:email]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be lowercased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [:email]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:database]` will
  # enable it only for database authentication. The supported strategies are:
  # :database      = Support basic authentication with authentication key + password
  config.http_authenticatable = [:pam, :database]

  # If 401 status code should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Application'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # See : https://github.com/plataformatec/devise/wiki/How-To:-Using-paranoid-mode,-avoid-user-enumeration-on-registerable
  config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments. Note that, for bcrypt (the default
  # encryptor), the cost increases exponentially with the number of stretches (e.g.
  # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 10

  # Setup a pepper to generate the encrypted password.
  # config.pepper = '104d16705f794923e77c5e5167b52452d00646dc952a2d30b541c24086e647012c7b9625f253c51912e455981e503446772973d5f1638631196c819d7137fad4'

  # Send a notification to the original email when the user's email is changed.
  config.send_email_changed_notification = true

  # Send a notification email when the user's password is changed
  config.send_password_change_notification = true

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming their account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming their account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming their account.
  # config.allow_unconfirmed_access_for = 2.days

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid. For example, if set to 3.days, the user can confirm
  # their account within 3 days after the mail was sent, but on the fourth day
  # their account can't be confirmed with the token any more.
  # Default is nil, meaning there is no restriction on how long a user can take
  # before confirming their account.
  config.confirm_within = 2.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed, new email is stored in
  # unconfirmed_email column, and copied to email column on successful confirmation.
  config.reconfirmable = true

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [:email]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  config.remember_for = 1.year

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..72

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  # config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  # config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # When set to false, does not sign a user in automatically after their password is
  # reset. Defaults to true, so a user is signed in automatically after a reset.
  config.sign_in_after_reset_password = false

  # ==> Configuration for :encryptable
  # Allow you to use another encryption algorithm besides bcrypt (default). You can use
  # :sha1, :sha512 or encryptors from others authentication tools as :clearance_sha1,
  # :authlogic_sha512 (then you should set stretches above to 20 for default behavior)
  # and :restful_authentication_sha1 (then you should set stretches to 10, and copy
  # REST_AUTH_SITE_KEY to pepper).
  #
  # Require the `devise-encryptable` gem when using anything other than bcrypt
  # config.encryptor = :sha512

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ['*/*', :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(scope: :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine
  #
  # When using OmniAuth, Devise cannot automatically set OmniAuth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/my_engine/users/auth'

  if ENV['PAM_ENABLED'] == 'true'
    config.pam_authentication     = true
    config.usernamefield          = nil
    config.emailfield             = 'email'
    config.check_at_sign          = true
    config.pam_default_suffix     = ENV.fetch('PAM_EMAIL_DOMAIN') { ENV['LOCAL_DOMAIN'] }
    config.pam_default_service    = ENV.fetch('PAM_DEFAULT_SERVICE') { 'rpam' }
    config.pam_controlled_service = ENV.fetch('PAM_CONTROLLED_SERVICE') { nil }
  end

  if ENV['LDAP_ENABLED'] == 'true'
    config.ldap_authentication = true
    config.check_at_sign       = true
    config.ldap_host           = ENV.fetch('LDAP_HOST', 'localhost')
    config.ldap_port           = ENV.fetch('LDAP_PORT', 389).to_i
    config.ldap_method         = ENV.fetch('LDAP_METHOD', :simple_tls).to_sym
    config.ldap_base           = ENV.fetch('LDAP_BASE')
    config.ldap_bind_dn        = ENV.fetch('LDAP_BIND_DN')
    config.ldap_password       = ENV.fetch('LDAP_PASSWORD')
    config.ldap_uid            = ENV.fetch('LDAP_UID', 'cn')
    config.ldap_mail           = ENV.fetch('LDAP_MAIL', 'mail')
    config.ldap_tls_no_verify  = ENV['LDAP_TLS_NO_VERIFY'] == 'true'
    config.ldap_search_filter  = ENV.fetch('LDAP_SEARCH_FILTER', '(|(%{uid}=%{email})(%{mail}=%{email}))')
    config.ldap_uid_conversion_enabled  = ENV['LDAP_UID_CONVERSION_ENABLED'] == 'true'
    config.ldap_uid_conversion_search   = ENV.fetch('LDAP_UID_CONVERSION_SEARCH', '.,- ')
    config.ldap_uid_conversion_replace  = ENV.fetch('LDAP_UID_CONVERSION_REPLACE', '_')
  end
end
