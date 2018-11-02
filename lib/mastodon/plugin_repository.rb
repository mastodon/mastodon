require_relative './plugin'

module Mastodon
  class PluginRepository
    include Singleton

    def initialize!
      return unless Dir.exists?('plugins')
      File.write 'config/plugins.yml', configure_plugins.to_yaml
    end

    private

    def configure_plugins
      default_config = { 'outlets' => Hash.new { [] }, 'assets' => [] }
      Dir["plugins/#{ENV.fetch('MASTODON_PLUGIN_SET', 'default')}/*/plugin.rb"].reduce(default_config) do |config, file|
        Dir.chdir(File.dirname(file)) do
          name  = File.dirname(file).split('/').last
          klass = "Mastodon::Plugins::#{name.camelize}"

          if load(File.basename(file)) && Object.const_defined?(klass)
            configure_plugin(config, klass.constantize.new)
          else
            puts "Unable to install plugin #{name}; check that the plugin has a plugin.rb file which defines a class named '#{klass}'"
          end

          config
        end
      end
    end

    def configure_plugin(config, plugin)
      plugin.setup!
      plugin.actions.map(&:call)

      config['assets'] += plugin.assets.to_a
      plugin.outlets.each do |outlet|
        config['outlets'].merge!({ outlet.name => [outlet.as_json.except('name')] }) { |_, a, b| Array(a) + Array(b) }
      end
    end
  end
end
