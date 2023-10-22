# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.initialize_on_precompile = true

Rails.application.config.assets.precompile += %w( registration_form.js )

Rails.application.config.assets.precompile += %w( application.js)
Rails.application.config.assets.precompile += %w( conditional_mediation_available.js )
Rails.application.config.assets.precompile += %w( passkey_reauthentication_handler.js)
Rails.application.config.assets.precompile += %w( session_form.js)
Rails.application.config.assets.precompile += %w( credential.js)
Rails.application.config.assets.precompile += %w( controllers/feature_detection_controller.js)
Rails.application.config.assets.precompile += %w( controllers/new_registration_controller.js)
Rails.application.config.assets.precompile += %w( controllers/new_session_controller.js)
Rails.application.config.assets.precompile += %w( controllers/application.js)
Rails.application.config.assets.precompile += %w( controllers/hello_controller.js)
Rails.application.config.assets.precompile += %w( controllers/index.js)

