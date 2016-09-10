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
      Account.where('(select count(f.id) from follows as f where f.target_account_id = accounts.id) = 0').where.not(domain: nil).find_each do |a|
        a.subscription('').unsubscribe
        a.update!(verify_token: '', secret: '')
      end
    end
  end

  namespace :feeds do
    desc 'Clears all timelines so that they would be regenerated on next hit'
    task clear: :environment do
      $redis.keys('feed:*').each { |key| $redis.del(key) }
    end
  end
end
