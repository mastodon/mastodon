require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

require 'yaml'

orm = if DOORKEEPER_ORM =~ /mongoid/
        Mongoid.load!(File.join(File.dirname(File.expand_path(__FILE__)), "#{DOORKEEPER_ORM}.yml"))
        :mongoid
      else
        DOORKEEPER_ORM
      end
require "#{orm}/railtie"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
