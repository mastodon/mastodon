require_relative './plugin'

module Mastodon
  class PluginRepository
    include Singleton

    def initialize!
      File.write 'app/javascript/packs/plugins.js', config[:requires].join("\n")
      File.write 'app/javascript/mastodon/outlets.js', ApplicationController.render(
        template: 'plugins/outlets',
        format: :js,
        assigns: config.slice(:outlets)
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
            configure_plugin(config, klass.constantize.new, path)
          else
            puts "Unable to install plugin #{name}; check that the plugin has a plugin.rb file which defines a class named '#{klass}'"
          end
          config
        end
      end
    end

    def configure_plugin(config, plugin, path)
      # call user-defined setup
      plugin.setup!

      # add outlets to file for adding to initial_state
      plugin.outlets.each do |outlet|
        config[:outlets][outlet.name] = config[:outlets][outlet.name] << outlet.as_json.except('name')
      end

      # add assets to file for webpacker to pick up
      plugin.assets.each { |asset| config[:requires] << "require('../../../#{asset}');" }

      # call all generic actions associated with this plugin
      plugin.actions.map(&:call)

      # add translations to load path
      Rails.application.config.i18n.load_path << [path, :locales, '*.yml'].join('/')
    end

    def plugin_path
      "plugins/#{ENV.fetch('MASTODON_PLUGIN_SET', 'default')}/*/plugin.rb"
    end

    def default_config
      { outlets: Hash.new { [] }, requires: [] }
    end
  end
end
