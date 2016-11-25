# frozen_string_literal: true

namespace :mastodon do
  namespace :media do
    desc 'Removes media attachments that have not been assigned to any status for longer than a day'
    task clear: :environment do
      MediaAttachment.where(status_id: nil).where('created_at < ?', 1.day.ago).find_each(&:destroy)
    end
  end

  namespace :push do
    desc 'Unsubscribes from PuSH updates of feeds nobody follows locally'
    task clear: :environment do
      include RoutingHelper

      Account.remote.without_followers.where.not(subscription_expires_at: nil).find_each do |a|
        Rails.logger.debug "PuSH unsubscribing from #{a.acct}"

        begin
          a.subscription(api_subscription_url(a.id)).unsubscribe
        rescue HTTP::Error, OpenSSL::SSL::SSLError
          Rails.logger.debug "PuSH unsubscribing from #{a.acct} failed due to an HTTP or SSL error"
        ensure
          a.update!(secret: '', subscription_expires_at: nil)
        end
      end
    end

    desc 'Re-subscribes to soon expiring PuSH subscriptions'
    task refresh: :environment do
      Account.expiring(1.day.from_now).find_each do |a|
        Rails.logger.debug "PuSH re-subscribing to #{a.acct}"
        SubscribeService.new.call(a)
      end
    end
  end

  namespace :feeds do
    desc 'Clear timelines of inactive users'
    task clear: :environment do
      User.where('current_sign_in_at < ?', 14.days.ago).find_each do |user|
        Redis.current.del(FeedManager.instance.key(:home, user.account_id))
        Redis.current.del(FeedManager.instance.key(:mentions, user.account_id))
      end
    end

    desc 'Clears all timelines so that they would be regenerated on next hit'
    task clear_all: :environment do
      Redis.current.keys('feed:*').each { |key| Redis.current.del(key) }
    end
  end
end
