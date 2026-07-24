# frozen_string_literal: true

# Integration library between Mastodon backend and Vite
module Vite
  autoload :Config, 'vite/config'
  autoload :DevServer, 'vite/dev_server'
  autoload :Proxy, 'vite/proxy'

  def self.setup
    yield config if block_given?
  end

  def self.config
    @config ||= Config.new
  end

  def self.dev_server
    @dev_server ||= DevServer.new(config)
  end
end
