require 'action_view/helpers'
require 'sprockets'

module Sprockets
  module Rails
    module Context
      include ActionView::Helpers::AssetUrlHelper
      include ActionView::Helpers::AssetTagHelper

      def self.included(klass)
        klass.class_eval do
          class_attribute :config, :assets_prefix, :digest_assets
        end
      end

      def compute_asset_path(path, options = {})
        @dependencies << 'actioncontroller-asset-url-config'

        begin
          asset_uri = resolve(path)
        rescue FileNotFound
          # TODO: eh, we should be able to use a form of locate that returns
          # nil instead of raising an exception.
        end

        if asset_uri
          asset = link_asset(path)
          digest_path = asset.digest_path
          path = digest_path if digest_assets
          File.join(assets_prefix || "/", path)
        else
          super
        end
      end
    end
  end

  register_dependency_resolver 'actioncontroller-asset-url-config' do |env|
    config = env.context_class.config
    [config.relative_url_root,
    (config.asset_host unless config.asset_host.respond_to?(:call))]
  end

  # fallback to the default pipeline when using Sprockets 3.x
  unless config[:pipelines].include? :debug
    register_pipeline :debug, config[:pipelines][:default]
  end
end
