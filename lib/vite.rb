# frozen_string_literal: true

# Integration library between Mastodon backend and Vite
module Vite
  autoload :Config, 'vite/config'
  autoload :DevServer, 'vite/dev_server'
  autoload :NameResolver, 'vite/name_resolver'
  autoload :Proxy, 'vite/proxy'
  autoload :Tagger, 'vite/tagger'
  autoload :TagsHelper, 'vite/tags_helper'

  def self.setup
    yield config if block_given?
  end

  def self.config
    @config ||= Config.new
  end

  def self.dev_server
    @dev_server ||= DevServer.new(config)
  end

  def self.tagger
    @tagger ||= Tagger.new(config)
  end
end
