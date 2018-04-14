# frozen_string_literal: true

require "webrick/httpproxy"

require "support/black_hole"
require "support/servers/config"
require "support/servers/runner"

class ProxyServer < WEBrick::HTTPProxyServer
  include ServerConfig

  CONFIG = {
    :BindAddress     => "127.0.0.1",
    :Port            => 0,
    :AccessLog       => BlackHole,
    :Logger          => BlackHole,
    :RequestCallback => proc { |_, res| res["X-PROXIED"] = true }
  }.freeze

  def initialize
    super CONFIG
  end
end

class AuthProxyServer < WEBrick::HTTPProxyServer
  include ServerConfig

  AUTHENTICATOR = proc do |req, res|
    WEBrick::HTTPAuth.proxy_basic_auth(req, res, "proxy") do |user, pass|
      user == "username" && pass == "password"
    end
  end

  CONFIG = ProxyServer::CONFIG.merge :ProxyAuthProc => AUTHENTICATOR

  def initialize
    super CONFIG
  end
end
