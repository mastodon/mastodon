# frozen_string_literal: true

module Mastodon
  class Application < Rails::Application
    config.x.mastodon = config_for(:mastodon)
  end
end
