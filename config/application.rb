# frozen_string_literal: true

require_relative 'boot'

require 'rails'

require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
# require 'action_cable/engine'
# require 'action_mailbox/engine'
# require 'action_text/engine'
# require 'rails/test_unit/railtie'

# Used to be implicitly required in action_mailbox/engine
require 'mail'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/active_record/batches'
require_relative '../lib/mastodon/rack_middleware'
require_relative '../lib/public_file_server_middleware'

Dotenv::Railtie.load

Bundler.require(:pam_authentication) if ENV['PAM_ENABLED'] == 'true'

require_relative '../config/redis'

module Mastodon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.active_record.marshalling_format_version = 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks templates generators linter))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    # config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.active_job.queue_adapter = :sidekiq

    config.action_mailer.deliver_later_queue_name = 'mailers'
    config.action_mailer.preview_paths << Rails.root.join('spec', 'mailers', 'previews')

    # We use our own middleware for this
    config.public_file_server.enabled = false

    config.middleware.use PublicFileServerMiddleware if Rails.env.local? || ENV['RAILS_SERVE_STATIC_FILES'] == 'true'
    config.middleware.use Rack::Attack
    config.middleware.use Mastodon::RackMiddleware

    initializer :deprecator do |app|
      app.deprecators[:mastodon] = ActiveSupport::Deprecation.new('4.3', 'mastodon/mastodon')
    end

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout 'modal'
      Doorkeeper::AuthorizedApplicationsController.layout 'admin'
      Doorkeeper::Application.include ApplicationExtension
      Doorkeeper::AccessToken.include AccessTokenExtension
      Devise::FailureApp.include AbstractController::Callbacks
      Devise::FailureApp.include Localized
      Webpacker::Manifest.prepend Webpacker::ManifestExtensions
      Webpacker::Helper.prepend Webpacker::HelperExtensions
      Chewy.extend Chewy::SettingsExtensions
      Chewy::Index.extend Chewy::IndexExtensions
      Rails::Engine.prepend Rails::EngineExtensions
      Paperclip::Attachment.prepend(Paperclip::AttachmentExtensions)
      Paperclip::MediaTypeSpoofDetector.prepend(Paperclip::MediaTypeSpoofDetectorExtensions)
      Paperclip::UrlGenerator.prepend(Paperclip::URLGeneratorExtensions)
    end
  end
end
