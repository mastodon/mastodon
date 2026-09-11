# frozen_string_literal: true

class Fasp::AnnounceContentLifecycleEventWorker < Fasp::BaseWorker
  sidekiq_options retry: 5

  def perform(uri, event_type)
    Fasp::Subscription.includes(:fasp_provider).category_content.lifecycle.each do |subscription|
      with_provider(subscription.fasp_provider) do
        announce(subscription, uri, event_type)
      end
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
