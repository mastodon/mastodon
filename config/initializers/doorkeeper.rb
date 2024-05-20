# frozen_string_literal: true

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (needs plugins)
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    current_user || redirect_to(new_user_session_url)
  end

  resource_owner_from_credentials do |_routes|
    user   = User.authenticate_with_ldap(email: request.params[:username], password: request.params[:password]) if Devise.ldap_authentication
    user ||= User.authenticate_with_pam(email: request.params[:username], password: request.params[:password]) if Devise.pam_authentication

    if user.nil?
      user = User.find_by(email: request.params[:username])
      user = nil unless user&.valid_password?(request.params[:password])
    end

    user unless user&.otp_required_for_login?
  end

  # Doorkeeper provides some administrative interfaces for managing OAuth
  # Applications, allowing creation, edit, and deletion of applications from the
  # server. At present, these administrative routes are not integrated into
  # Mastodon, and as such, we've disabled them by always return a 403 forbidden
  # response for them. This does not affect the ability for users to manage
  # their own OAuth Applications.
  admin_authenticator do
    head 403
  end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  access_token_expires_in nil

  # Assign a custom TTL for implicit grants.
  # custom_access_token_expires_in do |oauth_client|
  #   oauth_client.application.additional_settings.implicit_oauth_expiration
  # end

  # Use a custom class for generating the access token.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
  # access_token_generator "::Doorkeeper::JWT"

  # The controller Doorkeeper::ApplicationController inherits from.
  # Defaults to ActionController::Base.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
  base_controller 'ApplicationController'

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Forbids creating/updating applications with arbitrary scopes that are
  # not in configuration, i.e. `default_scopes` or `optional_scopes`.
  # (Disabled by default)
  enforce_configured_scopes

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  enable_application_owner

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  default_scopes  :read
  optional_scopes :write,
                  :'write:accounts',
                  :'write:blocks',
                  :'write:bookmarks',
                  :'write:conversations',
                  :'write:favourites',
                  :'write:filters',
                  :'write:follows',
                  :'write:lists',
                  :'write:media',
                  :'write:mutes',
                  :'write:notifications',
                  :'write:reports',
                  :'write:statuses',
                  :read,
                  :'read:me',
                  :'read:accounts',
                  :'read:blocks',
                  :'read:bookmarks',
                  :'read:favourites',
                  :'read:filters',
                  :'read:follows',
                  :'read:lists',
                  :'read:mutes',
                  :'read:notifications',
                  :'read:search',
                  :'read:statuses',
                  :follow,
                  :push,
                  :'admin:read',
                  :'admin:read:accounts',
                  :'admin:read:reports',
                  :'admin:read:domain_allows',
                  :'admin:read:domain_blocks',
                  :'admin:read:ip_blocks',
                  :'admin:read:email_domain_blocks',
                  :'admin:read:canonical_email_blocks',
                  :'admin:write',
                  :'admin:write:accounts',
                  :'admin:write:reports',
                  :'admin:write:domain_allows',
                  :'admin:write:domain_blocks',
                  :'admin:write:ip_blocks',
                  :'admin:write:email_domain_blocks',
                  :'admin:write:canonical_email_blocks',
                  :crypto

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
  # by default in non-development environments). OAuth2 delegates security in
  # communication to the HTTPS protocol so it is wise to keep this enabled.
  #
  force_ssl_in_redirect_uri false

  # Specify what redirect URI's you want to block during Application creation.
  # Any redirect URI is whitelisted by default.
  #
  # You can use this option in order to forbid URI's with 'javascript' scheme
  # for example.
  forbid_redirect_uri { |uri| %w(data vbscript javascript).include?(uri.scheme.to_s.downcase) }

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables authorization_code and
  # client_credentials.
  #
  # implicit and password grant flows have risks that you should understand
  # before enabling:
  #   http://tools.ietf.org/html/rfc6819#section-4.4.2
  #   http://tools.ietf.org/html/rfc6819#section-4.4.3
  #

  grant_flows %w(authorization_code password client_credentials)

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with a trusted application.
  skip_authorization do |_resource_owner, client|
    client.application.superapp?
  end

  # WWW-Authenticate Realm (default "Doorkeeper").
  # realm "Doorkeeper"
end
