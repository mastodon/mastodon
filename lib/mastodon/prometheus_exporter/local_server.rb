# frozen_string_literal: true

require 'prometheus_exporter/server'
require 'prometheus_exporter/client'

module Mastodon::PrometheusExporter
  module LocalServer
    def self.setup!
      # bind is the address, on which the webserver will listen
      # port is the port that will provide the /metrics route
      server = PrometheusExporter::Server::WebServer.new bind: ENV.fetch('MASTODON_PROMETHEUS_EXPORTER_HOST', 'localhost'), port: ENV.fetch('MASTODON_PROMETHEUS_EXPORTER_PORT', '9394').to_i
      server.start

      # wire up a default local client
      PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)
    end
  end
end
