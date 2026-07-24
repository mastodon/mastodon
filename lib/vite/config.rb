# frozen_string_literal: true

module Vite
  # TODO: Load config from file generated from `vite` command
  class Config
    attr_accessor :host, :port, :https, :base_path, :tag_strategies

    def initialize
      @host = 'localhost'
      @port = 3036
      @https = false
      @base_path = '/packs-dev/'
      @tag_strategies = [:dev_server, :manifest]
    end

    def https?
      !!https
    end

    def protocol
      https? ? 'https' : 'http'
    end

    def backend
      "#{protocol}://#{host}:#{port}"
    end
  end
end
