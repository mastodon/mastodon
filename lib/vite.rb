# frozen_string_literal: true

# Integration library between Mastodon backend and Vite
module Vite
  autoload :Builder, 'vite/builder'
  autoload :Config, 'vite/config'
  autoload :DevServer, 'vite/dev_server'
  autoload :Manifest, 'vite/manifest'
  autoload :NameResolver, 'vite/name_resolver'
  autoload :Proxy, 'vite/proxy'
  autoload :Tagger, 'vite/tagger'
  autoload :TagsHelper, 'vite/tags_helper'
  autoload :Tasks, 'vite/tasks'

  def self.setup
    yield config if block_given?
  end

  def self.config
    @config ||= Config.new
  end

  def self.logger
    @logger ||= config.logger
  end

  def self.dev_server
    @dev_server ||= DevServer.new(config:)
  end

  def self.tagger
    @tagger ||= Tagger.new(config:, manifest:, dev_server:)
  end

  def self.manifest
    @manifest ||= Manifest.new(config:, logger:)
  end

  def self.tasks
    @tasks ||= Vite::Tasks.new(config:)
  end

  def self.preload
    manifest.load
  rescue Vite::Manifest::MissingManifestError => e
    logger.error { e.message }
  end
end
