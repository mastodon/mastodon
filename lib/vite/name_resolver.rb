# frozen_string_literal: true

module Vite
  # When using assets in frontend views, we need to have an actual path that serves the asset.
  # This path needs to include:
  # - Vite's base_path, this is where the bundle is generated
  # - If the asset needs to be included inside the main entrypoints path or not
  #
  # For convenience assets that are single file names (i.e: application.ts) are considered to
  # be entrypoints. To make them work with Vite the `entrypoints/` prefix needs to be added.
  # If an asset is referenced with a relative path like `styles/application.scss`, that path
  # is used as is given.
  #
  # Examples:
  #   resolver = Vite::NameResolver.new(config: Vite.config)
  #   resolver.full_path('application.ts')
  #   # => '/packs-dev/entrypoints/application.ts'
  #   resolver.full_path('styles/application.scss')
  #   # => '/packs-dev/styles/application.scss'
  #
  # The #full_path is useful when working with Vite's dev server.
  # When serving asssets from a manifest, it is necessary to resolve first the #entrypoint_path
  # to have a proper reference of the asset inside the manifest file and then generate the
  # #bundle_path of the asset's real file name defined in the manifest
  class NameResolver
    attr_reader :config

    def initialize(config:)
      @config = config
    end

    # Full path to the given asset
    def full_path(name)
      bundle_path(entrypoint_path(name))
    end

    # Determines if an asset name should be considered an entrypoint and builds
    # the path accordingly
    def entrypoint_path(name)
      # If the name is a single file we assume it is inside app/javascripts/entrypoints
      name.include?('/') ? name : "entrypoints/#{name}"
    end

    # Asset's bundle path that includes Vite's base_path as a prefix
    def bundle_path(name)
      "#{config.base_path}#{name}"
    end
  end
end
