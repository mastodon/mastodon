# frozen_string_literal: true

require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    # Initialize Warden and copy its configurations.
    config.app_middleware.use Warden::Manager do |config|
      Devise.warden_config = config
    end

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load do |app|
      app.reload_routes! if Devise.reload_routes
    end

    initializer "devise.url_helpers" do
      Devise.include_helpers(Devise::Controllers)
    end

    initializer "devise.omniauth", after: :load_config_initializers, before: :build_middleware_stack do |app|
      Devise.omniauth_configs.each do |provider, config|
        app.middleware.use config.strategy_class, *config.args do |strategy|
          config.strategy = strategy
        end
      end

      if Devise.omniauth_configs.any?
        Devise.include_helpers(Devise::OmniAuth)
      end
    end

    initializer "devise.secret_key" do |app|
      Devise.secret_key ||= Devise::SecretKeyFinder.new(app).find

      Devise.token_generator ||=
        if secret_key = Devise.secret_key
          Devise::TokenGenerator.new(
            ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key))
          )
        end
    end
  end
end
