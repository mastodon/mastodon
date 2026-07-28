# frozen_string_literal: true

module Vite
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

    def copy_from(other)
      self.host = other[:host] unless other[:host].nil?
      self.port = other[:port] unless other[:port].nil?
      self.https = other[:https] unless other[:https].nil?
      self.base_path = other[:base_path] unless other[:base_path].nil?

      self.tag_strategies = other[:tag_strategies].map(&:to_sym) unless other[:tag_strategies].nil?
      self.manifest_path = other[:manifest_path] unless other[:manifest_path].nil?
      self.manifest_assets_path = other[:manifest_assets_path] unless other[:manifest_assets_path].nil?

      self.auto_build = other[:auto_build] unless other[:auto_build].nil?
      self.build_command = other[:build_command] unless other[:build_command].nil?
    end
  end
end
