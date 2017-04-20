# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << 'node_modules'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(custom.css)

# Skin assets
if ENV['SKIN'] and not ENV['SKIN'].empty?
  for skin in ENV['SKIN'].split("|") do
    Rails.application.config.assets.precompile += [skin + ".css", skin + ".js"]
  end
else
  Rails.application.config.assets.precompile += %w(rooty.css rooty.js)
end

# Frontend assets
if ENV['FRONTEND'] and not ENV['FRONTEND'].empty?
  for frontend in ENV['FRONTEND'].split("|") do
    Rails.application.config.assets.precompile += [frontend + ".css", frontend + ".js"]
  end
else
  Rails.application.config.assets.precompile += %w(tooty.css tooty.js)
end

Rails.application.config.assets.initialize_on_precompile = true
