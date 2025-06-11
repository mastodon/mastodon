# frozen_string_literal: true

require 'prometheus_exporter/server'
require 'prometheus_exporter/client'

module Mastodon::PrometheusExporter
  module LocalServer
    mattr_accessor :bind, :port

    def self.setup!
      server = PrometheusExporter::Server::WebServer.new(bind:, port:)
      server.start

      # wire up a default local client
      PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)
    end
  end
end
