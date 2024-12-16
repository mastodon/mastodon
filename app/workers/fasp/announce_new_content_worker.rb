# frozen_string_literal: true

class Fasp::AnnounceNewContentWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'fasp', retry: 5

  def perform(uri)
    Fasp::Subscription.includes(:fasp_provider).content.lifecycle.each do |subscription|
      announce(subscription, uri)
    end
  end

  private

  def announce(subscription, uri)
    Fasp::Request.new(subscription.fasp_provider).post('/data_sharing/v0/announcements', body: {
      source: {
        subscription: {
          id: subscription.id.to_s,
        },
      },
      category: 'content',
      eventType: 'new',
      objectUris: [uri],
    })
  end
end
