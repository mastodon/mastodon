require "active_support/core_ext/module/attribute_accessors"
require "active_support/logger"
require "active_support/tagged_logging"

module Webpacker
  extend self

  def instance=(instance)
    @instance = instance
  end

  def instance
    @instance ||= Webpacker::Instance.new
  end

  def with_node_env(env)
    original = ENV["NODE_ENV"]
    ENV["NODE_ENV"] = "production"
    yield
  ensure
    ENV["NODE_ENV"] = original
  end

  delegate :logger, :logger=, :env, to: :instance
  delegate :config, :compiler, :manifest, :commands, :dev_server, to: :instance
  delegate :bootstrap, :clobber, :compile, to: :commands
end

require "webpacker/instance"
require "webpacker/env"
require "webpacker/configuration"
require "webpacker/manifest"
require "webpacker/compiler"
require "webpacker/commands"
require "webpacker/dev_server"

require "webpacker/railtie" if defined?(Rails)
