# frozen_string_literal: true

begin
  require "omniauth"
  require "omniauth/version"
rescue LoadError
  warn "Could not load 'omniauth'. Please ensure you have the omniauth gem >= 1.0.0 installed and listed in your Gemfile."
  raise
end

unless OmniAuth::VERSION =~ /^1\./
  raise "You are using an old OmniAuth version, please ensure you have 1.0.0.pr2 version or later installed."
end

# Clean up the default path_prefix. It will be automatically set by Devise.
OmniAuth.config.path_prefix = nil

OmniAuth.config.on_failure = Proc.new do |env|
  env['devise.mapping'] = Devise::Mapping.find_by_path!(env['PATH_INFO'], :path)
  controller_name  = ActiveSupport::Inflector.camelize(env['devise.mapping'].controllers[:omniauth_callbacks])
  controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
  controller_klass.action(:failure).call(env)
end

module Devise
  module OmniAuth
    autoload :Config,      "devise/omniauth/config"
    autoload :UrlHelpers,  "devise/omniauth/url_helpers"
  end
end
