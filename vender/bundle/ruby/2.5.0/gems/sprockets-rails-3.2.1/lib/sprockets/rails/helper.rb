require 'action_view'
require 'sprockets'
require 'active_support/core_ext/class/attribute'
require 'sprockets/rails/utils'

module Sprockets
  module Rails
    module Helper
      class AssetNotFound < StandardError; end

      class AssetNotPrecompiled < StandardError
        include Sprockets::Rails::Utils
        def initialize(source)
          msg =
          if using_sprockets4?
            "Asset `#{ source }` was not declared to be precompiled in production.\n" +
            "Declare links to your assets in `app/assets/config/manifest.js`.\n\n" +
            "  //= link #{ source }\n" +
            "and restart your server"
          else
            "Asset was not declared to be precompiled in production.\n" +
            "Add `Rails.application.config.assets.precompile += " +
            "%w( #{source} )` to `config/initializers/assets.rb` and " +
            "restart your server"
          end
          super(msg)
        end
      end

      include ActionView::Helpers::AssetUrlHelper
      include ActionView::Helpers::AssetTagHelper
      include Sprockets::Rails::Utils

      VIEW_ACCESSORS = [
        :assets_environment, :assets_manifest,
        :assets_precompile, :precompiled_asset_checker,
        :assets_prefix, :digest_assets, :debug_assets,
        :resolve_assets_with, :check_precompiled_asset,
        :unknown_asset_fallback
      ]

      def self.included(klass)
        klass.class_attribute(*VIEW_ACCESSORS)

        klass.class_eval do
          remove_method :assets_environment
          def assets_environment
            if instance_variable_defined?(:@assets_environment)
              @assets_environment = @assets_environment.cached
            elsif env = self.class.assets_environment
              @assets_environment = env.cached
            else
              nil
            end
          end
        end
      end

      def self.extended(obj)
        obj.class_eval do
          attr_accessor(*VIEW_ACCESSORS)

          remove_method :assets_environment
          def assets_environment
            if env = @assets_environment
              @assets_environment = env.cached
            else
              nil
            end
          end
        end
      end

      # Writes over the built in ActionView::Helpers::AssetUrlHelper#compute_asset_path
      # to use the asset pipeline.
      def compute_asset_path(path, options = {})
        debug = options[:debug]

        if asset_path = resolve_asset_path(path, debug)
          File.join(assets_prefix || "/", legacy_debug_path(asset_path, debug))
        else
          message =  "The asset #{ path.inspect } is not present in the asset pipeline."
          raise AssetNotFound, message unless unknown_asset_fallback

          if respond_to?(:public_compute_asset_path)
            message << "Falling back to an asset that may be in the public folder.\n"
            message << "This behavior is deprecated and will be removed.\n"
            message << "To bypass the asset pipeline and preserve this behavior,\n"
            message << "use the `skip_pipeline: true` option.\n"

            call_stack = Kernel.respond_to?(:caller_locations) && ::Rails::VERSION::MAJOR >= 5 ? caller_locations : caller
            ActiveSupport::Deprecation.warn(message, call_stack)
          end
          super
        end
      end

      # Resolve the asset path against the Sprockets manifest or environment.
      # Returns nil if it's an asset we don't know about.
      def resolve_asset_path(path, allow_non_precompiled = false) #:nodoc:
        resolve_asset do |resolver|
          resolver.asset_path path, digest_assets, allow_non_precompiled
        end
      end

      # Expand asset path to digested form.
      #
      # path    - String path
      # options - Hash options
      #
      # Returns String path or nil if no asset was found.
      def asset_digest_path(path, options = {})
        resolve_asset do |resolver|
          resolver.digest_path path, options[:debug]
        end
      end

      # Experimental: Get integrity for asset path.
      #
      # path    - String path
      # options - Hash options
      #
      # Returns String integrity attribute or nil if no asset was found.
      def asset_integrity(path, options = {})
        path = path_with_extname(path, options)

        resolve_asset do |resolver|
          resolver.integrity path
        end
      end

      # Override javascript tag helper to provide debugging support.
      #
      # Eventually will be deprecated and replaced by source maps.
      def javascript_include_tag(*sources)
        options = sources.extract_options!.stringify_keys
        integrity = compute_integrity?(options)

        if options["debug"] != false && request_debug_assets?
          sources.map { |source|
            if asset = lookup_debug_asset(source, type: :javascript)
              if asset.respond_to?(:to_a)
                asset.to_a.map do |a|
                  super(path_to_javascript(a.logical_path, debug: true), options)
                end
              else
                super(path_to_javascript(asset.logical_path, debug: true), options)
              end
            else
              super(source, options)
            end
          }.flatten.uniq.join("\n").html_safe
        else
          sources.map { |source|
            options = options.merge('integrity' => asset_integrity(source, type: :javascript)) if integrity
            super source, options
          }.join("\n").html_safe
        end
      end

      # Override stylesheet tag helper to provide debugging support.
      #
      # Eventually will be deprecated and replaced by source maps.
      def stylesheet_link_tag(*sources)
        options = sources.extract_options!.stringify_keys
        integrity = compute_integrity?(options)

        if options["debug"] != false && request_debug_assets?
          sources.map { |source|
            if asset = lookup_debug_asset(source, type: :stylesheet)
              if asset.respond_to?(:to_a)
                asset.to_a.map do |a|
                  super(path_to_stylesheet(a.logical_path, debug: true), options)
                end
              else
                super(path_to_stylesheet(asset.logical_path, debug: true), options)
              end
            else
              super(source, options)
            end
          }.flatten.uniq.join("\n").html_safe
        else
          sources.map { |source|
            options = options.merge('integrity' => asset_integrity(source, type: :stylesheet)) if integrity
            super source, options
          }.join("\n").html_safe
        end
      end

      protected
        # This is awkward: `integrity` is a boolean option indicating whether
        # we want to include or omit the subresource integrity hash, but the
        # options hash is also passed through as literal tag attributes.
        # That means we have to delete the shortcut boolean option so it
        # doesn't bleed into the tag attributes, but also check its value if
        # it's boolean-ish.
        def compute_integrity?(options)
          if secure_subresource_integrity_context?
            case options['integrity']
            when nil, false, true
              options.delete('integrity') == true
            end
          else
            options.delete 'integrity'
            false
          end
        end

        # Only serve integrity metadata for HTTPS requests:
        #   http://www.w3.org/TR/SRI/#non-secure-contexts-remain-non-secure
        def secure_subresource_integrity_context?
          respond_to?(:request) && self.request && (self.request.local? || self.request.ssl?)
        end

        # Enable split asset debugging. Eventually will be deprecated
        # and replaced by source maps in Sprockets 3.x.
        def request_debug_assets?
          debug_assets || (defined?(controller) && controller && params[:debug_assets])
        rescue # FIXME: what exactly are we rescuing?
          false
        end

        # Internal method to support multifile debugging. Will
        # eventually be removed w/ Sprockets 3.x.
        def lookup_debug_asset(path, options = {})
          path = path_with_extname(path, options)

          resolve_asset do |resolver|
            resolver.find_debug_asset path
          end
        end

        # compute_asset_extname is in AV::Helpers::AssetUrlHelper
        def path_with_extname(path, options)
          path = path.to_s
          "#{path}#{compute_asset_extname(path, options)}"
        end

        # Try each asset resolver and return the first non-nil result.
        def resolve_asset
          asset_resolver_strategies.detect do |resolver|
            if result = yield(resolver)
              break result
            end
          end
        end

        # List of resolvers in `config.assets.resolve_with` order.
        def asset_resolver_strategies
          @asset_resolver_strategies ||=
            Array(resolve_assets_with).map do |name|
              HelperAssetResolvers[name].new(self)
            end
        end

        # Append ?body=1 if debug is on and we're on old Sprockets.
        def legacy_debug_path(path, debug)
          if debug && !using_sprockets4?
            "#{path}?body=1"
          else
            path
          end
        end
    end

    # Use a separate module since Helper is mixed in and we needn't pollute
    # the class namespace with our internals.
    module HelperAssetResolvers #:nodoc:
      def self.[](name)
        case name
        when :manifest
          Manifest
        when :environment
          Environment
        else
          raise ArgumentError, "Unrecognized asset resolver: #{name.inspect}. Expected :manifest or :environment"
        end
      end

      class Manifest #:nodoc:
        def initialize(view)
          @manifest = view.assets_manifest
          raise ArgumentError, 'config.assets.resolve_with includes :manifest, but app.assets_manifest is nil' unless @manifest
        end

        def asset_path(path, digest, allow_non_precompiled = false)
          if digest
            digest_path path, allow_non_precompiled
          end
        end

        def digest_path(path, allow_non_precompiled = false)
          @manifest.assets[path]
        end

        def integrity(path)
          if meta = metadata(path)
            meta["integrity"]
          end
        end

        def find_debug_asset(path)
          nil
        end

        private
          def metadata(path)
            if digest_path = digest_path(path)
              @manifest.files[digest_path]
            end
          end
      end

      class Environment #:nodoc:
        def initialize(view)
          raise ArgumentError, 'config.assets.resolve_with includes :environment, but app.assets is nil' unless view.assets_environment
          @env = view.assets_environment
          @precompiled_asset_checker = view.precompiled_asset_checker
          @check_precompiled_asset = view.check_precompiled_asset
        end

        def asset_path(path, digest, allow_non_precompiled = false)
          # Digests enabled? Do the work to calculate the full asset path.
          if digest
            digest_path path, allow_non_precompiled

          # Otherwise, ask the Sprockets environment whether the asset exists
          # and check whether it's also precompiled for production deploys.
          elsif asset = find_asset(path)
            raise_unless_precompiled_asset asset.logical_path unless allow_non_precompiled
            path
          end
        end

        def digest_path(path, allow_non_precompiled = false)
          if asset = find_asset(path)
            raise_unless_precompiled_asset asset.logical_path unless allow_non_precompiled
            asset.digest_path
          end
        end

        def integrity(path)
          find_asset(path).try :integrity
        end

        def find_debug_asset(path)
          if asset = find_asset(path, pipeline: :debug)
            raise_unless_precompiled_asset asset.logical_path.sub('.debug', '')
            asset
          end
        end

        private
          def find_asset(path, options = {})
            @env[path, options]
          end

          def precompiled?(path)
            @precompiled_asset_checker.call path
          end

          def raise_unless_precompiled_asset(path)
            raise Helper::AssetNotPrecompiled.new(path) if @check_precompiled_asset && !precompiled?(path)
          end
      end
    end
  end
end
