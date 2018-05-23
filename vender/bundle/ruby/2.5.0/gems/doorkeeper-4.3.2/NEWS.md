# News

User-visible changes worth mentioning.

## master

## 4.3.2

- [#1053] Support authorizing with query params in the request `redirect_uri` if explicitly present in app's `Application#redirect_uri`

## 4.3.1

- Remove `BaseRecord` and introduce additional concern for ordering methods to fix
  braking changes for Doorkeeper models.
- [#1032] Refactor BaseRequest callbacks into configurable lambdas
- [#1040] Clear mixins from ActiveRecord DSL and save only overridable API. It
  allows to use this mixins in Doorkeeper ORM extensions with minimum code boilerplate.

## 4.3.0

- [#976] Fix to invalidate the second redirect URI when the first URI is the native URI
- [#1035] Allow `Application#redirect_uri=` to handle array of URIs.
- [#1036] Allow to forbid Application redirect URI's with specific rules.
- [#1029] Deprecate `order_method` and introduce `ordered_by`. Sort applications
  by `created_at` in index action.
- [#1033] Allow Doorkeeper configuration option #force_ssl_in_redirect_uri to be a callable object.
- Fix Grape integration & add specs for it
- [#913] Deferred ORM (ActiveRecord) models loading
- [#943] Fix Access Token token generation when certain errors occur in custom token generators
- [#1026] Implement RFC7662 - OAuth 2.0 Token Introspection
- [#985] Generate valid migration files for Rails >= 5
- [#972] Replace Struct subclassing with block-form initialization
- [#1003] Use URL query param to pass through native redirect auth code so automated apps can find it.
- [#868] `Scopes#&` and `Scopes#+` now take an array or any other enumerable
  object.
- [#1019] Remove translation not in use: `invalid_resource_owner`.
- Use Ruby 2 hash style syntax (min required Ruby version = 2.1)
- [#948] Make Scopes.<=> work with any "other" value.
- [#974] Redirect URI is checked without query params within AuthorizationCodeRequest.
- [#1004] More explicit help text for `native_redirect_uri`.
- [#1023] Update Ruby versions and test against 2.5.0 on Travis CI.
- [#1024] Migrate from FactoryGirl to FactoryBot.
- [#1025] Improve documentation for adding foreign keys
- [#1028] Make it possible to have composite strategy names.

## 4.2.6

- [#970] Escape certain attributes in authorization forms.

## 4.2.5

- [#936] Deprecate `Doorkeeper#configured?`, `Doorkeeper#database_installed?`, and
  `Doorkeeper#installed?`
- [#909] Add `InvalidTokenResponse#reason` reader method to allow read the kind
  of invalid token error.
- [#928] Test against more recent Ruby versions
- Small refactorings within the codebase
- [#921] Switch to Appraisal, and test against Rails master
- [#892] Add minimum Ruby version requirement

## 4.2.0

- Security fix: Address CVE-2016-6582, implement token revocation according to
    spec (tokens might not be revoked if client follows the spec).
- [#873] Add hooks to Doorkeeper::ApplicationMetalController
- [#871] Allow downstream users to better utilize doorkeeper spec factories by
  eliminating name conflict on `:user` factory.

## 4.1.0

- [#845] Allow customising the `Doorkeeper::ApplicationController` base
  controller

## 4.0.0

- [#834] Fix AssetNotPrecompiled error with Sprockets 4
- [#843] Revert "Fix validation error messages"
- [#847] Specify Null option to timestamps

## 4.0.0.rc4

- [#777] Add support for public client in password grant flow
- [#823] Make configuration and specs ORM independent
- [#745] Add created_at timestamp to token generation options
- [#838] Drop `Application#scopes` generator and warning, introduced for
  upgrading doorkeeper from v2 to v3.
- [#801] Fix Rails 5 warning messages
- Test against Rails 5 RC1

## 4.0.0.rc3

- [#769] Revoke refresh token on access token use. To make use of the new config
  add `previous_refresh_token` column to `oauth_access_tokens`:

  ```
  rails generate doorkeeper:previous_refresh_token
  ```
- [#811] Toughen parameters filter with exact match
- [#813] Applications admin bugfix
- [#799] Fix Ruby Warnings
- Drop `attr_accessible` from models

### Backward incompatible changes

- [#730] Force all timezones to use UTC to prevent comparison issues.
- [#802] Remove `config.i18n.fallbacks` from engine

## 4.0.0.rc2

- Fix optional belongs_to for Rails 5
- Fix Ruby warnings

## 4.0.0.rc1

### Backward incompatible changes

- Drops support for Rails 4.1 and earlier
- Drops support for Ruby 2.0
- [#778] Bug fix: use the remaining time that a token is still valid when
  building the redirect URI for the implicit grant flow

### Other changes

- [#771] Validation error messages fixes
- Adds foreign key constraints in generated migrations between tokens and
  grants, and applications
- Support Rails 5

## 3.1.0

- [#736] Existing valid tokens are now reused in client_credentials flow
- [#749] Allow user to raise authorization error with custom messages.
  Under `resource_owner_authenticator` block a user can
  `raise Doorkeeper::Errors::DoorkeeperError.new('custom_message')`
- [#762] Check doesn’t abort the actual migration, so it runs
- [#722] `doorkeeper_forbidden_render_options` now supports returning a 404 by
  specifying `respond_not_found_when_forbidden: true` in the
  `doorkeeper_forbidden_render_options` method.
- [#734] Simplify and remove duplication in request strategy classes

## 3.0.1

- [#712] Wrap exchange of grant token for access token and access token refresh
  in transactions
- [#704] Allow applications scopes to be mass assigned
- [#707] Fixed order of Mixin inclusion and table_name configuration in models
- [#712] Wrap access token and refresh grants in transactions
- Adds JRuby support
- Specs, views and documentation adjustments

## 3.0.0

### Other changes

- [#693] Updates `en.yml`.

## 3.0.0 (rc2)

### Backward incompatible changes

- [#678] Change application-specific scopes to take precedence over server-wide
  scopes. This removes the previous behavior where the intersection between
  application and server scopes was used.

### Other changes

- [#671] Fixes `NoMethodError - undefined method 'getlocal'` when calling
  the /oauth/token path. Switch from using a DateTime object to update
  AR to using a Time object. (Issue #668)
- [#677] Support editing application-specific scopes via the standard forms
- [#682] Pass error hash to Grape `error!`
- [#683] Generate application secret/UID if fields are blank strings

## 3.0.0 (rc1)

### Backward incompatible changes

- [#648] Extracts mongodb ORMs to
  https://github.com/doorkeeper-gem/doorkeeper-mongodb. If you use ActiveRecord
  you don’t need to do any change, otherwise you will need to install the new
  plugin.
- [#665] `doorkeeper_unauthorized_render_options(error:)` and
  `doorkeeper_forbidden_render_options(error:)` now accept `error` keyword
  argument.

### Removed deprecations

- Removes `doorkeeper_for` deprecation notice.
- Remove `applications.scopes` upgrade notice.


## 2.2.2

- [#541] Fixed `undefined method attr_accessible` problem on Rails 4
    (happens only when ProtectedAttributes gem is used) in #599

## 2.2.1

- [#636] `custom_access_token_expires_in` bugfixes
- [#641] syntax error fix (Issue #612)
- [#633] Send extra details to Custom Token Generator
- [#628] Refactor: improve orm adapters to ease extension
- [#637] Upgrade to rspec to 3.2

## 2.2.0 - 2015-04-19

- [#611] Allow custom access token generators to be used
- [#632] Properly fallback to `default_scopes` when no scope is specified
- [#622] Clarify that there is a logical OR between scopes for authorizing
- [#635] Upgrade to rspec 3
- [#627] i18n fallbacks to english
- Moved CHANGELOG to NEWS.md


## 2.1.4 - 2015-03-27

- [#595] HTTP spec: Add `scope` for refresh token scope param
- [#596] Limit scopes in app scopes for client credentials
- [#567] Add Grape helpers for easier integration with Grape framework
- [#606] Add custom access token expiration support for Client Credentials flow


## 2.1.3 - 2015-03-01

- [#588] Fixes scopes_match? bug that skipped authorization form in some cases


## 2.1.2 - 2015-02-25

- [#574] Remove unused update authorization route.
- [#576] Filter out sensitive parameters from logs.
- [#582] The Authorization HTTP header fields are now case insensitive.
- [#583] Database connection bugfix in certain scenarios.
- Testing improvements


## 2.1.1 - 2015-02-06

- Remove `wildcard_redirect_url` option
- [#481] Customize token flow OAuth expirations with a config lambda
- [#568] TokensController: Memoize strategy.authorize_response result to enable
    subclasses to use the response object.
- [#571] Fix database initialization issues in some configurations.
- Documentation improvements


## 2.1.0 - 2015-01-13

- [#540] Include `created_at` in response.
- [#538] Check application-level scopes in client_credentials and password flow.
- [5596227] Check application scopes in AccessToken when present. Fixes a bug in
  doorkeeper 2.0.0 and 2.0.1 referring to application specific scopes.
- [#534] Internationalizes doorkeeper views.
- [#545] Ensure there is a connection to the database before checking for
  missing columns
- [#546] Use `Doorkeeper::` prefix when referencing `Application` to avoid
  possible application model name conflict.
- [#538] Test with Rails ~> 4.2.

### Potentially backward incompatible changes

- Enable by default `authorization_code` and `client_credentials` grant flows.
  Disables implicit and password grant flows by default.
- [#510, #544, 722113f] Revoked refresh token response bugfix.


## 2.0.1 - 2014-12-17

- [#525, #526, #527] Fix `ActiveRecord::NoDatabaseError` on gem load.


## 2.0.0 - 2014-12-16

### Backward incompatible changes

- [#448] Removes `doorkeeper_for` helper. Now we use
  `before_action :doorkeeper_authorize!`.
- [#469] Allow client applications to restrict the set of allowable scopes.
  Fixes #317. `oauth_applications` relation needs a new `scopes` string column,
  non nullable, which defaults to an empty string. To add the column run:

  ```
  rails generate doorkeeper:application_scopes
  ```

  If you’d rather do it by hand, your ActiveRecord migration should contain:

  ```ruby
  add_column :oauth_applications, :scopes, :string, null: false, default: ‘’
  ```

### Removed deprecations

- Removes `test_redirect_uri` option. It is now called `native_redirect_uri`.
- [#446] Removes `mount Doorkeeper::Engine`. Now we use `use_doorkeeper`.

### Others

- [#484] Performance improvement - avoid performing order_by when not required.
- [#450] When password is invalid in Password Credentials Grant, Doorkeeper
  returned 'invalid_resource_owner' instead of 'invalid_grant', as the spec
  declares. Fixes #444.
- [#452] Allows `revoked_at` to be set in the future, for future expiry.
  Rationale: https://github.com/doorkeeper-gem/doorkeeper/pull/452#issuecomment-51431459
- [#480] For Implicit grant flow, access tokens can now be reused. Fixes #421.
- [#491] Reworks of @jasl's #454 and #478. ORM refactor that allows doorkeeper
  to be extended more easily with unsupported ORMs. It also marks the boundaries
  between shared model code and ORM specifics inside of the gem.
- [#496] Tests with Rails 4.2.
- [#489] Adds `force_ssl_in_redirect_uri` to force the usage of the HTTPS
  protocol in non-native redirect uris.
- [#516] SECURITY: Adds `protect_from_forgery` to `Doorkeeper::ApplicationController`
- [#518] Fix random failures in mongodb.

---

## 1.4.2 - 2015-03-02

- [#576] Filter out sensitive parameters from logs

## 1.4.1 - 2014-12-17

- [#516] SECURITY: Adds `protect_from_forgery` to `Doorkeeper::ApplicationController`

## 1.4.0 - 2014-07-31

- internals
  - [#427] Adds specs expectations.
  - [#428] Error response refactor.
  - [#417] Moves token validation into Access Token class.
  - [#439] Removes redundant module includes.
  - [#443] TokensController and TokenInfoController inherit from ActionController::Metal
- bug
  - [#418] fixes #243, requests with insufficient scope now respond 403 instead
    of 401. (API change)
  - [#438] fixes #398, native redirect for implicit token grant bug.
  - [#440] namespace fixes
- enhancements
  - [#432] Keeps query parameters

## 1.3.1 - 2014-07-06

- enhancements
  - [#405] Adds facade to more easily get the token from a request in a route
    constraint.
  - [#415] Extend Doorkeeper TokenResponse with an `after_successful_response`
    callback that allows handling of `response` object.
- internals
  - [#409] Deprecates `test_redirect_uri` in favor of `native_redirect_uri`.
    See discussion in: [#351].
  - [#411] Clean rspec deprecations. General test improvements.
  - [#412] rspec line width can go longer than 80 (hound CI config).
- bug
  - [#413] fixes #340, routing scope is now taken into account in redirect.
  - [#401] and [#425] application is not required any longer for access_token.

## 1.3.0 - 2014-05-23

- enhancements
  - [#387] Adds reuse_access_token configuration option.

## 1.2.0 - 2014-05-02

- enhancements
  - [#376] Allow users to enable basic header authorization for access tokens.
  - [#374] Token revocation implementation [RFC 7009]
  - [#295] Only enable specific grant flows.
- internals
  - [#381] Locale source fix.
  - [#380] Renames `errors_for` to `doorkeeper_errors_for`.
  - [#390] Style adjustments in accordance with Ruby Style Guide form
    Thoughtbot.

## 1.1.0 - 2014-03-29

- enhancements
  - [#336] mongoid4 support.
  - [#372] Allow users to set ActiveRecord table_name_prefix/suffix options
- internals
  - [#343] separate OAuth's admin and user end-point to different layouts, upgrade theme to Bootstrap 3.1.
  - [#348] Move render_options in filter after `@error` has been set

## 1.0.0 - 2014-01-13

- bug (spec)
  - [#228] token response `expires_in` value is now in seconds, relative to
    request time
  - [#296] client is optional for password grant type.
  - [#319] If client credentials are present on password grant type they are validated
  - [#326] If client credentials are present in refresh token they are validated
  - [#326] If authenticated client does not match original client that
    obtained a refresh token it responds `invalid_grant` instead of
    `invalid_client`. Previous usage was invalid according to Section 5.2 of
    the spec.
  - [#329] access tokens' `scopes` string wa being compared against
    `default_scopes` symbols, always unauthorizing.
  - [#318] Include "WWW-Authenticate" header with Unauthorized responses
- enhancements
  - [#293] Adds ActionController::Instrumentation in TokensController
  - [#298] Support for multiple redirect_uris added.
  - [#313] `AccessToken.revoke_all_for` actually revokes all non-revoked
    tokens for an application/owner instead of deleting them.
  - [#333] Rails 4.1 support
- internals
  - Removes jQuery dependency [fixes #300] [PR #312 is related]
  - [#294] Client uid and secret will be generated only if not present.
  - [#316] Test warnings addressed.
  - [#338] Rspec 3 syntax.

---

## 0.7.4 - 2013-12-01

- bug
  - Symbols instead of strings for user input.

## 0.7.3 - 2013-10-04

- enhancements
  - [#204] Allow to overwrite scope in routes
- internals
  - Returns only present keys in Token Response (may imply a backwards
    incompatible change). https://github.com/doorkeeper-gem/doorkeeper/issues/220
- bug
  - [#290] Support for Rails 4 when 'protected_attributes' gem is present.

## 0.7.2 - 2013-09-11

- enhancements
  - [#272] Allow issuing multiple access_tokens for one user/application for multiple devices
  - [#170] Increase length of allowed redirect URIs
  - [#239] Do not try to load unavailable Request class for the current phase.
  - [#273] Relax jquery-rails gem dependency

## 0.7.1 - 2013-08-30

- bug
  - [#269] Rails 3.2 raised `ActiveModel::MassAssignmentSecurity::Error`.

## 0.7.0 - 2013-08-21

- enhancements
  - [#229] Rails 4!
- internals
  - [#203] Changing table name to be specific in column_names_with_table
  - [#215] README update
  - [#227] Use Rails.config.paths["config/routes"] instead of assuming "config/routes.rb" exists
  - [#262] Add jquery as gem dependency
  - [#263] Add a configuration for ActiveRecord.establish_connection
  - Deprecation and Ruby warnings (PRs merged outside of GitHub).

## 0.6.7 - 2013-01-13

- internals
  - [#188] Add IDs to the show views for integration testing [@egtann](https://github.com/egtann)

## 0.6.6 - 2013-01-04

- enhancements
  - [#187] Raise error if configuration is not set

## 0.6.5 - 2012-12-26

- enhancements
  - [#184] Vendor the Bootstrap CSS [@tylerhunt](https://github.com/tylerhunt)

## 0.6.4 - 2012-12-15

- bug
  - [#180] Add localization to authorized_applications destroy notice [@aalvarado](https://github.com/aalvarado)

## 0.6.3 - 2012-12-07

- bugfixes
  - [#163] Error response content-type header should be application/json [@ggayan](https://github.com/ggayan)
  - [#175] Make token.expires_in_seconds return nil when expires_in is nil [@miyagawa](https://github.com/miyagawa)
- enhancements
  - [#166, #172, #174] Behavior to automatically authorize based on a configured proc
- internals
  - [#168] Using expectation syntax for controller specs [@rdsoze](https://github.com/rdsoze)

## 0.6.2 - 2012-11-10

- bugfixes
  - [#162] Remove ownership columns from base migration template [@rdsoze](https://github.com/rdsoze)

## 0.6.1 - 2012-11-07

- bugfixes
  - [#160] Removed |routes| argument from initializer authenticator blocks
- documentation
  - [#160] Fixed description of context of authenticator blocks

## 0.6.0 - 2012-11-05

- enhancements
  - Mongoid `orm` configuration accepts only :mongoid2 or :mongoid3
  - Authorization endpoint does not redirect in #new action anymore. It wasn't specified by OAuth spec
  - TokensController now inherits from ActionController::Metal. There might be performance upgrades
  - Add link to authorization in Applications scaffold
  - [#116] MongoMapper support [@carols10cents](https://github.com/carols10cents)
  - [#122] Mongoid3 support [@petergoldstein](https://github.com/petergoldstein)
  - [#150] Introduce test redirect uri for applications
- bugfixes
  - [#157] Response token status should be `:ok`, not `:success` [@theycallmeswift](https://github.com/theycallmeswift)
  - [#159] Remove ActionView::Base.field_error_proc override (fixes #145)
- internals
  - Update development dependencies
  - Several refactorings
  - Rails/ORM are easily swichable with env vars (rails and orm)
  - Travis now tests against Mongoid v2

## 0.5.0 - 2012-10-20

Official support for rubinius was removed.

- enhancements
  - Configure the way access token is retrieved from request (default to bearer header)
  - Authorization Code expiration time is now configurable
  - Add support for mongoid
  - [#78, #128, #137, #138] Application Ownership
  - [#92] Allow users to skip controllers
  - [#99] Remove deprecated warnings for data-* attributes [@towerhe](https://github.com/towerhe)
  - [#101] Return existing access_token for PasswordAccessTokenRequest [@benoist](https://github.com/benoist)
  - [#104] Changed access token scopes example code to default_scopes and optional_scopes [@amkirwan](https://github.com/amkirwan)
  - [#107] Fix typos in initializer
  - [#123] i18n for validator, flash messages [@petergoldstein](https://github.com/petergoldstein)
  - [#140] ActiveRecord is the default value for the ORM [@petergoldstein](https://github.com/petergoldstein)
- internals
  - [#112, #120] Replacing update_attribute with update_column to eliminate deprecation warnings [@rmoriz](https://github.com/rmoriz), [@petergoldstein](https://github.com/petergoldstein)
  - [#121] Updating all development dependencies to recent versions. [@petergoldstein](https://github.com/petergoldstein)
  - [#144] Adding MongoDB dependency to .travis.yml [@petergoldstein](https://github.com/petergoldstein)
  - [#143] Displays errors for unconfigured error messages [@timgaleckas](https://github.com/timgaleckas)
- bugfixes
  - [#102] Not returning 401 when access token generation fails [@cslew](https://github.com/cslew)
  - [#125] Doorkeeper is using ActiveRecord version of as_json in ORM agnostic code [@petergoldstein](https://github.com/petergoldstein)
  - [#142] Prevent double submission of password based authentication [@bdurand](https://github.com/bdurand)
- documentation
  - [#141] Add rack-cors middleware to readme [@gottfrois](https://github.com/gottfrois)

## 0.4.2 - 2012-06-05

- bugfixes:
  - [#94] Uninitialized Constant in Password Flow

## 0.4.1 - 2012-06-02

- enhancements:
  - Backport: Move doorkeeper_for extension to Filter helper

## 0.4.0 - 2012-05-26

- deprecation
  - Deprecate authorization_scopes
- database changes
  - AccessToken#resource_owner_id is not nullable
- enhancements
  - [#83] Add Resource Owner Password Credentials flow [@jaimeiniesta](https://github.com/jaimeiniesta)
  - [#76] Allow token expiration to be disabled [@mattgreen](https://github.com/mattgreen)
  - [#89] Configure the way client credentials are retrieved from request
  - [#b6470a] Add Client Credentials flow
- internals
  - [#2ece8d, #f93778] Introduce Client and ErrorResponse classes

## 0.3.4 - 2012-05-24

- Fix attr_accessible for rails 3.2.x

## 0.3.3 - 2012-05-07

- [#86] shrink gem package size

## 0.3.2 - 2012-04-29

- enhancements
  - [#54] Ignore Authorization: headers that are not Bearer [@miyagawa](https://github.com/miyagawa)
  - [#58, #64] Add destroy action to applications endpoint [@jaimeiniesta](https://github.com/jaimeiniesta), [@davidfrey](https://github.com/davidfrey)
  - [#63] TokensController responds with `401 unauthorized` [@jaimeiniesta](https://github.com/jaimeiniesta)
  - [#67, #72] Fix for mass-assignment [@cicloid](https://github.com/cicloid)
- internals
  - [#49] Add Gemnasium status image to README [@laserlemon](https://github.com/laserlemon)
  - [#50] Fix typos [@tomekw](https://github.com/tomekw)
  - [#51] Updated the factory_girl_rails dependency, fix expires_in response which returned a float number instead of integer [@antekpiechnik](https://github.com/antekpiechnik)
  - [#62] Typos, .gitignore [@jaimeiniesta](https://github.com/jaimeiniesta)
  - [#65] Change _path redirections to _url redirections [@jaimeiniesta](https://github.com/jaimeiniesta)
  - [#75] Fix unknown method #authenticate_admin! [@mattgreen](https://github.com/mattgreen)
  - Remove application link in authorized app view

## 0.3.1 - 2012-02-17

- enhancements
  - [#48] Add if, else options to doorkeeper_for
  - Add views generator
- internals
  - Namespace models

## 0.3.0 - 2012-02-11

- enhancements
  - [#17, #31] Add support for client credentials in basic auth header [@GoldsteinTechPartners](https://github.com/GoldsteinTechPartners)
  - [#28] Add indices to migration [@GoldsteinTechPartners](https://github.com/GoldsteinTechPartners)
  - [#29] Allow doorkeeper to run with rails 3.2 [@john-griffin](https://github.com/john-griffin)
  - [#30] Improve client's redirect uri validation [@GoldsteinTechPartners](https://github.com/GoldsteinTechPartners)
  - [#32] Add token (implicit grant) flow [@GoldsteinTechPartners](https://github.com/GoldsteinTechPartners)
  - [#34] Add support for custom unathorized responses [@GoldsteinTechPartners](https://github.com/GoldsteinTechPartners)
  - [#36] Remove repetitions from the Authorised Applications view [@carvil](https://github.com/carvil)
  - When user revoke an application, all tokens for that application are revoked
  - Error messages now can be translated
  - Install generator copies the error messages localization file
- internals
  - Fix deprecation warnings in ActiveSupport::Base64
  - Remove deprecation in doorkeeper_for that handles hash arguments
  - Depends on railties instead of whole rails framework
  - CI now integrates with rails 3.1 and 3.2

## 0.2.0 - 2011-12-17

- enhancements
  - [#4] Add authorized applications endpoint
  - [#5, #11] Add access token scopes
  - [#10] Add access token expiration by default
  - [#9, #12] Add refresh token flow
- internals
  - [#7] Improve configuration options with :default
  - Improve configuration options with :builder
  - Refactor config class
  - Improve coverage of authorization request integration
- bug fixes
  - [#6, #20] Fix access token response headers
  - Fix issue with state parameter
- deprecation
  - deprecate :only and :except options in doorkeeper_for

## 0.1.1 - 2011-11-30

- enhancements
  - [#3] Authorization code must be short lived and single use
  - [#2] Improve views provided by doorkeeper
  - [#1] Skips authorization form if the client has been authorized by the resource owner
  - Improve readme
- bugfixes
  - Fix issue when creating the access token (wrong client id)

## 0.1.0 - 2011-11-25

- Authorization Code flow
- OAuth applications endpoint
