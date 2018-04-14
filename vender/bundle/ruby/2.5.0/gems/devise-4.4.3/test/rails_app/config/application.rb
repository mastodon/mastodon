# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"

Bundler.require :default, DEVISE_ORM

begin
  require "#{DEVISE_ORM}/railtie"
rescue LoadError
end

require "devise"

module RailsApp
  class Application < Rails::Application
    # Add additional load paths for your own custom dirs
    config.autoload_paths.reject!{ |p| p =~ /\/app\/(\w+)$/ && !%w(controllers helpers mailers views).include?($1) }
    config.autoload_paths += ["#{config.root}/app/#{DEVISE_ORM}"]

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, fixture: true
    # end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
    # config.assets.enabled = false

    config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
    rails_version = Gem::Version.new(Rails.version)
    if DEVISE_ORM == :active_record &&
       rails_version >= Gem::Version.new('4.2.0') &&
       rails_version < Gem::Version.new('5.1.0')
      config.active_record.raise_in_transactional_callbacks = true
    end

    # This was used to break devise in some situations
    config.to_prepare do
      Devise::SessionsController.layout "application"
    end
  end
end
