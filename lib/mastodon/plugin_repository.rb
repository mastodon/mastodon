# frozen_string_literal: true
require_relative './plugin'

module Mastodon
  class PluginRepository
    include Singleton

    def initialize!
      File.write 'app/javascript/packs/plugins.js', config[:requires].join("\n")
      File.write 'app/javascript/mastodon/pluginConfig.js', ApplicationController.render(
        template: 'plugins/config',
        format: :js,
        assigns: config.slice(:outlets, :locales)
      )
    end

    private

    def config
      @config ||= Dir[plugin_path].reduce(default_config) do |config, file|
        path = File.dirname(file)
        name  = path.split('/').last
        klass = "Mastodon::Plugins::#{name.camelize}"

        Dir.chdir(path) do
          if load('plugin.rb') && Object.const_defined?(klass)
            configure_plugin(config, klass.constantize)
          else
            Rails.logger.warn "Unable to install plugin #{name}; check that the plugin has a plugin.rb file which defines a class named '#{klass}'"
          end
          config
        end
      end
    end

    def configure_plugin(config, plugin)
      # add outlet and translation information
      plugin.paths.each do |p|
        config[p.type][p.name] = config[p.type][p.name] << "require('../../../#{p.path}')"
      end

      # add assets to file for webpacker to pick up
      plugin.assets.each { |asset| config[:requires] << "require('../../../#{asset}');" }

      # call all generic actions associated with this plugin
      plugin.actions.map(&:call)
    end

    def plugin_path
      "plugins/#{ENV.fetch('MASTODON_PLUGIN_SET', 'default')}/*/plugin.rb"
    end

    def default_config
      { outlets: Hash.new { [] }, locales: Hash.new { [] }, requires: [] }
    end
  end
end
