# frozen_string_literal: true

# Integration library between Mastodon backend and Vite
module Vite
  autoload :Config, 'vite/config'
  autoload :Proxy, 'vite/proxy'

  def self.setup
    yield config if block_given?
  end

  def self.config
    @config ||= Config.new
  end
end
