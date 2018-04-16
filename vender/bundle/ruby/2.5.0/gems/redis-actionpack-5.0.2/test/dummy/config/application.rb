require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"

Bundler.require

module Dummy
  class Application < Rails::Application
    # Disable class caching for session auto-load test
    config.cache_classes = false

    config.eager_load = false

    # Show full error reports and disable caching
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    # Raise exceptions instead of rendering exception templates
    config.action_dispatch.show_exceptions = false

    # Disable request forgery protection in test environment
    config.action_controller.allow_forgery_protection    = false

    # Print deprecation notices to the stderr
    config.active_support.deprecation = :stderr

    config.secret_key_base = 'secret'
  end
end

