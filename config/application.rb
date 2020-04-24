require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../app/lib/exceptions'
require_relative '../lib/paperclip/lazy_thumbnail'
require_relative '../lib/paperclip/gif_transcoder'
require_relative '../lib/paperclip/video_transcoder'
require_relative '../lib/mastodon/snowflake'
require_relative '../lib/mastodon/version'
require_relative '../lib/devise/ldap_authenticatable'

Dotenv::Railtie.load

Bundler.require(:pam_authentication) if ENV['PAM_ENABLED'] == 'true'

require_relative '../lib/mastodon/redis_config'

module Mastodon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # All translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [
      :en,
      :ar,
      :ast,
      :bg,
      :ca,
      :co,
      :cs,
      :cy,
      :da,
      :de,
      :el,
      :eo,
      :es,
      :eu,
      :fa,
      :fi,
      :fr,
      :gl,
      :he,
      :hr,
      :hu,
      :hy,
      :id,
      :io,
      :it,
      :ja,
      :ka,
      :ko,
      :lv,
      :ms,
      :nl,
      :no,
      :oc,
      :pl,
      :pt,
      :'pt-BR',
      :ro,
      :ru,
      :sk,
      :sl,
      :sq,
      :sr,
      :'sr-Latn',
      :sv,
      :ta,
      :te,
      :th,
      :tr,
      :uk,
      :vi,
      :'zh-CN',
      :'zh-HK',
      :'zh-TW',
    ]

    config.i18n.default_locale = ENV['DEFAULT_LOCALE']&.to_sym

    unless config.i18n.available_locales.include?(config.i18n.default_locale)
      config.i18n.default_locale = :en
    end

    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    # config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.active_job.queue_adapter = :sidekiq

    config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout 'modal'
      Doorkeeper::AuthorizedApplicationsController.layout 'admin'
      Doorkeeper::Application.send :include, ApplicationExtension
    end
  end
end
