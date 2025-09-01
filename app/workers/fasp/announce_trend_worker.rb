# frozen_string_literal: true

class Fasp::AnnounceTrendWorker < Fasp::BaseWorker
  sidekiq_options retry: 5

  def perform(status_id, trend_source)
    status = ::Status.includes(:account).find(status_id)
    return unless status.account.indexable?

    Fasp::Subscription.includes(:fasp_provider).category_content.trends.each do |subscription|
      with_provider(subscription.fasp_provider) do
        announce(subscription, status.uri) if trending?(subscription, status, trend_source)
      end
    end
  rescue ActiveRecord::RecordNotFound
    # status might not exist anymore, in which case there is nothing to do
  end

  private

  def trending?(subscription, status, trend_source)
    scope = scope_for(status, trend_source)
    threshold = threshold_for(subscription, trend_source)
    scope.where(created_at: subscription.timeframe_start..).count >= threshold
  end

  def scope_for(status, trend_source)
    case trend_source
    when 'favourite'
      status.favourites
    when 'reblog'
      status.reblogs
    when 'reply'
      status.replies
    end
  end

  def threshold_for(subscription, trend_source)
    case trend_source
    when 'favourite'
      subscription.threshold_likes
    when 'reblog'
      subscription.threshold_shares
    when 'reply'
      subscription.threshold_replies
    end
  end

  def announce(subscription, uri)
    Fasp::Request.new(subscription.fasp_provider).post('/data_sharing/v0/announcements', body: {
      source: {
        subscription: {
          id: subscription.id.to_s,
        },
      },
      category: 'content',
      eventType: 'trending',
      objectUris: [uri],
    })
  end
end
