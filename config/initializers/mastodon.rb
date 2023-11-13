module Mastodon
  class Application < Rails::Application
    config.x.mastodon = config_for(:mastodon)
  end
end
