# frozen_string_literal: true

require 'rails/generators'
require 'fileutils'

module Rails
  class MastodonPluginGenerator < Rails::Generators::NamedBase
    def generate_plugin
      path = "plugins/#{ENV.fetch('MASTODON_PLUGIN_SET', 'default')}"
      FileUtils.mkdir path, noop: true
      template 'plugin.rb', "#{path}/#{file_name}/plugin.rb"
    end

    def plugin_class_name
      file_name.camelize
    end
  end
end
