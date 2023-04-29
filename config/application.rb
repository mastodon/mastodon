require_relative 'boot'

require 'rails'

require 'active_record/railtie'
#require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
#require 'action_cable/engine'
#require 'action_mailbox/engine'
#require 'action_text/engine'
#require 'rails/test_unit/railtie'
require 'sprockets/railtie'

# Used to be implicitly required in action_mailbox/engine
require 'mail'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/exceptions'
require_relative '../lib/sanitize_ext/sanitize_config'
require_relative '../lib/redis/namespace_extensions'
require_relative '../lib/paperclip/url_generator_extensions'
require_relative '../lib/paperclip/attachment_extensions'
require_relative '../lib/paperclip/lazy_thumbnail'
require_relative '../lib/paperclip/gif_transcoder'
require_relative '../lib/paperclip/transcoder'
require_relative '../lib/paperclip/type_corrector'
require_relative '../lib/paperclip/response_with_limit_adapter'
require_relative '../lib/terrapin/multi_pipe_extensions'
require_relative '../lib/mastodon/snowflake'
require_relative '../lib/mastodon/version'
require_relative '../lib/mastodon/rack_middleware'
require_relative '../lib/public_file_server_middleware'
require_relative '../lib/devise/two_factor_ldap_authenticatable'
require_relative '../lib/devise/two_factor_pam_authenticatable'
require_relative '../lib/chewy/strategy/mastodon'
require_relative '../lib/chewy/strategy/bypass_with_warning'
require_relative '../lib/webpacker/manifest_extensions'
require_relative '../lib/webpacker/helper_extensions'
require_relative '../lib/rails/engine_extensions'
require_relative '../lib/action_controller/conditional_get_extensions'
require_relative '../lib/active_record/database_tasks_extensions'
require_relative '../lib/active_record/batches'
require_relative '../lib/simple_navigation/item_extensions'

Dotenv::Railtie.load

Bundler.require(:pam_authentication) if ENV['PAM_ENABLED'] == 'true'

require_relative '../lib/mastodon/redis_config'

module Mastodon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.add_autoload_paths_to_load_path = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # All translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [
      :af,
      :an,
      :ar,
      :ast,
      :be,
      :bg,
      :bn,
      :br,
      :bs,
      :ca,
      :ckb,
      :co,
      :cs,
      :cy,
      :da,
      :de,
      :el,
      :en,
      :'en-GB',
      :eo,
      :es,
      :'es-AR',
      :'es-MX',
      :et,
      :eu,
      :fa,
      :fi,
      :fo,
      :fr,
      :'fr-QC',
      :fy,
      :ga,
      :gd,
      :gl,
      :he,
      :hi,
      :hr,
      :hu,
      :hy,
      :id,
      :ig,
      :io,
      :is,
      :it,
      :ja,
      :ka,
      :kab,
      :kk,
      :kn,
      :ko,
      :ku,
      :kw,
      :la,
      :lt,
      :lv,
      :mk,
      :ml,
      :mr,
      :ms,
      :my,
      :nl,
      :nn,
      :no,
      :oc,
      :pa,
      :pl,
      :'pt-BR',
      :'pt-PT',
      :ro,
      :ru,
      :sa,
      :sc,
      :sco,
      :si,
      :sk,
      :sl,
      :sq,
      :sr,
      :'sr-Latn',
      :sv,
      :szl,
      :ta,
      :te,
      :th,
      :tr,
      :tt,
      :ug,
      :uk,
      :ur,
      :vi,
      :zgh,
      :'zh-CN',
      :'zh-HK',
      :'zh-TW',
    ]

    config.i18n.default_locale = begin
      custom_default_locale = ENV['DEFAULT_LOCALE']&.to_sym

      if config.i18n.available_locales.include?(custom_default_locale)
        custom_default_locale
      else
        :en
      end
    end

    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    # config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'mailers'

    # We use our own middleware for this
    config.public_file_server.enabled = false

    config.middleware.use PublicFileServerMiddleware if Rails.env.development? || ENV['RAILS_SERVE_STATIC_FILES'] == 'true'
    config.middleware.use Rack::Attack
    config.middleware.use Mastodon::RackMiddleware

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout 'modal'
      Doorkeeper::AuthorizedApplicationsController.layout 'admin'
      Doorkeeper::Application.send :include, ApplicationExtension
      Doorkeeper::AccessToken.send :include, AccessTokenExtension
      Devise::FailureApp.send :include, AbstractController::Callbacks
      Devise::FailureApp.send :include, Localized
    end
  end
end
