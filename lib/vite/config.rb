# frozen_string_literal: true

module Vite
  # TODO: Load config from file generated from `vite` command
  class Config
    attr_accessor :host,
                  :port,
                  :https,
                  :base_path,
                  :tag_strategies,
                  :manifest_path,
                  :manifest_assets_path,
                  :auto_build,
                  :build_command

    def initialize
      @host = 'localhost'
      @port = 3036
      @https = false
      @base_path = '/packs-dev/'
      @tag_strategies = [:dev_server, :manifest]

      # TODO: Setup full path using Rails.root or Rails.public_path
      @manifest_path = 'public/packs-dev/.vite/manifest.json'
      @manifest_assets_path = 'public/packs-dev/.vite/manifest-assets.json'

      @auto_build = true
      @build_command = 'yarn build:development'
    end

    def https?
      https
    end

    def protocol
      https? ? 'https' : 'http'
    end

    def backend
      "#{protocol}://#{host}:#{port}"
    end

    def auto_build?
      auto_build
    end
  end
end
