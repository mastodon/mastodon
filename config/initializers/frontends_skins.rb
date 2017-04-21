# frozen_string_literal: true

Rails.application.configure do
  if ENV['SKIN'] and not ENV['SKIN'].empty?
    config.x.skins = ENV['SKIN'].split('|')
    config.x.skin_default = config.x.skins.first
  else
    config.x.skins = ["rooty"]
    config.x.skin_default = "rooty"
  end
  if ENV['FRONTEND'] and not ENV['FRONTEND'].empty?
    config.x.frontends = ENV['FRONTEND'].split('|')
    config.x.frontend_default = config.x.frontends.first
  else
    config.x.frontends = ["tooty"]
    config.x.frontend_default = "tooty"
  end
end
