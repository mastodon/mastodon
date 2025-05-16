# frozen_string_literal: true

class Fasp::AnnounceContentLifecycleEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'fasp', retry: 5

  def perform(uri, event_type)
    Fasp::Subscription.includes(:fasp_provider).content.lifecycle.each do |subscription|
      announce(subscription, uri, event_type)
    end
  end

  private

  def announce(subscription, uri, event_type)
    Fasp::Request.new(subscription.fasp_provider).post('/data_sharing/v0/announcements', body: {
      source: {
        subscription: {
          id: subscription.id.to_s,
        },
      },
      category: 'content',
      eventType: event_type,
      objectUris: [uri],
    })
  end
end
