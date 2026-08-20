# frozen_string_literal: true

module Vite
  # Main configuration options to integrate with Vite:
  # - host: Main host for Vite's dev server. Default: localhost
  # - port: Main port for Vite's dev server. Default: 5173
  # - https: Whether to use HTTPS to connect to the dev server or not. Default: false
  # - base_path: The prefix path added to the assets. Default: /packs-dev/
  # - tag_strategies: How to generate javascript and stylesheet tags in views. Possible values are:
  #   * dev_server: Generate tags linking directly to the dev server through an internal proxy
  #   * manifest: Generate tags using assets listed in Vite's manifest files
  #   Default: [:dev_server, :manifest]
  # - manifest_path: Where the manifest file is located. Default: public/packs-dev/.vite/manifest.json
  # - manifest_assets_path: Where the manifest-assets file is located. Default: public/packs-dev/.vite/manifest-assets.json
  # - auto_build: Whether to automatically build assets or not. This is useful for tess. Default: false
  # - build_command: How to build assets when auto_build is enabled. Default: 'yarn build:development'
  # - out_dir: Output dir for built assets. Default: 'public/packs-dev'
  # - cache_dir: Vite's build cache path. Default: 'node_modules/.vite'
  # - logger: Main logger instance for other Vite classes. Default: Logger.new($stdout)
  class Config
    attr_accessor :host,
                  :port,
                  :https,
                  :base_path,
                  :tag_strategies,
                  :manifest_path,
                  :manifest_assets_path,
                  :auto_build,
                  :build_command,
                  :out_dir,
                  :cache_dir,
                  :logger

    def initialize(cnf = nil)
      @host = 'localhost'
      @port = 5173
      @https = false
      @base_path = '/packs-dev/'

      @tag_strategies = [:dev_server, :manifest]
      @manifest_path = 'public/packs-dev/.vite/manifest.json'
      @manifest_assets_path = 'public/packs-dev/.vite/manifest-assets.json'

      @auto_build = false
      @build_command = 'yarn build:development'

      @out_dir = 'public/packs-dev'
      @cache_dir = 'node_modules/.vite'

      @logger = Logger.new($stdout)

      copy_from(cnf) unless cnf.nil?
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

      self.out_dir = other[:out_dir] unless other[:out_dir].nil?
      self.cache_dir = other[:cache_dir] unless other[:cache_dir].nil?

      self.auto_build = other[:auto_build] unless other[:auto_build].nil?
      self.build_command = other[:build_command] unless other[:build_command].nil?
    end
  end
end
