# frozen_string_literal: true

require "webrick"
require "webrick/ssl"

require "support/black_hole"
require "support/dummy_server/servlet"
require "support/servers/config"
require "support/servers/runner"
require "support/ssl_helper"

class DummyServer < WEBrick::HTTPServer
  include ServerConfig

  CONFIG = {
    :BindAddress  => "127.0.0.1",
    :Port         => 0,
    :AccessLog    => BlackHole,
    :Logger       => BlackHole
  }.freeze

  SSL_CONFIG = CONFIG.merge(
    :SSLEnable            => true,
    :SSLStartImmediately  => true
  ).freeze

  def initialize(options = {}) # rubocop:disable Style/OptionHash
    super(options[:ssl] ? SSL_CONFIG : CONFIG)
    mount("/", Servlet)
  end

  def endpoint
    "#{scheme}://#{addr}:#{port}"
  end

  def scheme
    config[:SSLEnable] ? "https" : "http"
  end

  def ssl_context
    @ssl_context ||= SSLHelper.server_context
  end
end
