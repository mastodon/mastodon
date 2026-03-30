# frozen_string_literal: true

class Fasp::BaseWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'fasp'

  private

  def with_provider(provider)
    return unless provider.confirmed? && provider.available?

    yield
  rescue *Mastodon::HTTP_CONNECTION_ERRORS
    raise if provider.available?
  ensure
    provider.update_availability!
  end
end
