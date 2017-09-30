# frozen_string_literal: true

require_relative '../../app/lib/provider_discovery'
OEmbed::Providers.register_fallback(ProviderDiscovery)
