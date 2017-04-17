# frozen_string_literal: true

namespace :mastodon do
  desc 'Execute daily tasks'
  task :daily do
    Rake::Task['mastodon:feeds:clear'].invoke
    Rake::Task['mastodon:media:clear'].invoke
    Rake::Task['mastodon:users:clear'].invoke

    Rake::Task['mastodon:push:refresh'].invoke
  end

  desc 'Turn a user into an admin, identified by the USERNAME environment variable'
  task make_admin: :environment do
    include RoutingHelper

    user = Account.find_local(ENV.fetch('USERNAME')).user
    user.update(admin: true)

    puts "Congrats! #{user.account.username} is now an admin. \\o/\nNavigate to #{admin_settings_url} to get started"
  end

  desc 'Manually confirms a user with associated user email address stored in USER_EMAIL environment variable.'
  task confirm_email: :environment do
    email = ENV.fetch('USER_EMAIL')
    user  = User.find_by(email: email)

    if user
      user.update(confirmed_at: Time.now.utc)
      puts "#{email} confirmed"
    else
      abort "#{email} not found"
    end
  end

  namespace :media do
    desc 'Removes media attachments that have not been assigned to any status for longer than a day'
    task clear: :environment do
      MediaAttachment.where(status_id: nil).where('created_at < ?', 1.day.ago).find_each(&:destroy)
    end

    desc 'Remove media attachments attributed to silenced accounts'
    task remove_silenced: :environment do
      MediaAttachment.where(account: Account.silenced).find_each(&:destroy)
    end

    desc 'Remove cached remote media attachments that are older than a week'
    task remove_remote: :environment do
      MediaAttachment.where.not(remote_url: '').where('created_at < ?', 1.week.ago).find_each do |media|
        media.file.destroy
      end
    end
  end

  namespace :push do
    desc 'Unsubscribes from PuSH updates of feeds nobody follows locally'
    task clear: :environment do
      Account.remote.without_followers.where.not(subscription_expires_at: nil).find_each do |a|
        Rails.logger.debug "PuSH unsubscribing from #{a.acct}"
        UnsubscribeService.new.call(a)
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
      User.confirmed.where('current_sign_in_at < ?', 14.days.ago).find_each do |user|
        Redis.current.del(FeedManager.instance.key(:home, user.account_id))
      end
    end

    desc 'Clears all timelines'
    task clear_all: :environment do
      Redis.current.keys('feed:*').each { |key| Redis.current.del(key) }
    end
  end

  namespace :emails do
    desc 'Send out digest e-mails'
    task digest: :environment do
      User.confirmed.joins(:account).where(accounts: { silenced: false, suspended: false }).where('current_sign_in_at < ?', 20.days.ago).find_each do |user|
        DigestMailerWorker.perform_async(user.id)
      end
    end
  end

  namespace :users do
    desc 'Clear out unconfirmed users'
    task clear: :environment do
      # Users that never confirmed e-mail never signed in, means they
      # only have a user record and an avatar record, with no files uploaded
      User.where('confirmed_at is NULL AND confirmation_sent_at <= ?', 2.days.ago).find_in_batches do |batch|
        Account.where(id: batch.map(&:account_id)).delete_all
        User.where(id: batch.map(&:id)).delete_all
      end
    end
  end

  namespace :settings do
    desc 'Open registrations on this instance'
    task open_registrations: :environment do
      setting = Setting.where(var: 'open_registrations').first
      setting.value = true
      setting.save
    end

    desc 'Close registrations on this instance'
    task close_registrations: :environment do
      setting = Setting.where(var: 'open_registrations').first
      setting.value = false
      setting.save
    end
  end

  namespace :maintenance do
    desc 'Update counter caches'
    task update_counter_caches: :environment do
      Rails.logger.debug 'Updating counter caches for accounts...'

      Account.unscoped.select('id').find_in_batches do |batch|
        Account.where(id: batch.map(&:id)).update_all('statuses_count = (select count(*) from statuses where account_id = accounts.id), followers_count = (select count(*) from follows where target_account_id = accounts.id), following_count = (select count(*) from follows where account_id = accounts.id)')
      end

      Rails.logger.debug 'Updating counter caches for statuses...'

      Status.unscoped.select('id').find_in_batches do |batch|
        Status.where(id: batch.map(&:id)).update_all('favourites_count = (select count(*) from favourites where favourites.status_id = statuses.id), reblogs_count = (select count(*) from statuses as reblogs where reblogs.reblog_of_id = statuses.id)')
      end

      Rails.logger.debug 'Done!'
    end

    desc 'Generate static versions of GIF avatars/headers'
    task add_static_avatars: :environment do
      Rails.logger.debug 'Generating static avatars/headers for GIF ones...'

      Account.unscoped.where(avatar_content_type: 'image/gif').or(Account.unscoped.where(header_content_type: 'image/gif')).find_each do |account|
        begin
          account.avatar.reprocess!
          account.header.reprocess!
        rescue StandardError => e
          Rails.logger.error "Error while generating static avatars/headers for account #{account.id}: #{e}"
          next
        end
      end

      Rails.logger.debug 'Done!'
    end
  end
end
