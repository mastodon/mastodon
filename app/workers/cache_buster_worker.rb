# frozen_string_literal: true

class CacheBusterWorker
  include Sidekiq::Worker
  include RoutingHelper

  sidekiq_options queue: 'pull'

  def perform(path)
    cache_buster.bust(full_asset_url(path))
  end

  private

  def cache_buster
    CacheBuster.new(Rails.configuration.x.cache_buster)
  end
end
