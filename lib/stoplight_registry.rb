# frozen_string_literal: true

require 'concurrent/map'

# Keep track of created lights to avoid recreating them
# NOTE: In theory, Stoplight v6 will have a registry built
class StoplightRegistry
  attr_reader :registry

  def self.current
    @current ||= new
  end

  def self.fetch(light, **)
    current.fetch(light, **)
  end

  def initialize
    @registry = Concurrent::Map.new
  end

  def fetch(light, **)
    MastodonOTELTracer.in_span('StoplightRegistry#fetch', attributes: { 'stoplight.name' => light }) do
      registry.compute_if_absent(light) { Stoplight.light(light, **) }
    end
  end
end
