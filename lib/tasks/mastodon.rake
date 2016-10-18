namespace :mastodon do
  namespace :media do
    desc 'Removes media attachments that have not been assigned to any status for longer than a day'
    task clear: :environment do
      MediaAttachment.where(status_id: nil).where('created_at < ?', 1.day.ago).find_each do |m|
        m.destroy
      end
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
        SubscribeService.new.(a)
      end
    end
  end

  namespace :feeds do
    desc 'Clears all timelines so that they would be regenerated on next hit'
    task clear: :environment do
      $redis.keys('feed:*').each { |key| $redis.del(key) }
    end
  end

  namespace :graphs do
    desc 'Syncs all follow relationships to Neo4J'
    task sync: :environment do
      Follow.find_each(&:sync!)
    end
  end
end
