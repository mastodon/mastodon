# frozen_string_literal: true

namespace :mastodon do
  desc 'Execute daily tasks'
  task daily: :environment do
    MastodonTasksService.daily
    puts "Completed daily tasks at #{Time.now.utc}"
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
      MastodonTasksService::Media.clear
    end

    desc 'Remove media attachments attributed to silenced accounts'
    task remove_silenced: :environment do
      MastodonTasksService::Media.remove_silenced
    end

    desc 'Remove cached remote media attachments that are older than a week'
    task remove_remote: :environment do
      MastodonTasksService::Media.remove_remote
    end
  end

  namespace :push do
    desc 'Unsubscribes from PuSH updates of feeds nobody follows locally'
    task clear: :environment do
      MastodonTasksService::Push.clear
    end

    desc 'Re-subscribes to soon expiring PuSH subscriptions'
    task refresh: :environment do
      MastodonTasksService::Push.refresh
    end
  end

  namespace :feeds do
    desc 'Clear timelines of inactive users'
    task clear: :environment do
      MastodonTasksService::Feeds.clear
    end

    desc 'Clears all timelines'
    task clear_all: :environment do
      MastodonTasksService::Feeds.clear_all
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
      MastodonTasksService::Users.clear
    end

    desc 'List all admin users'
    task admins: :environment do
      MastodonTasksService::Users.admins
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
          account.avatar.reprocess! if account.avatar_content_type == 'image/gif' && !account.avatar.exists?(:static)
          account.header.reprocess! if account.header_content_type == 'image/gif' && !account.header.exists?(:static)
        rescue StandardError => e
          Rails.logger.error "Error while generating static avatars/headers for account #{account.id}: #{e}"
          next
        end
      end

      Rails.logger.debug 'Done!'
    end
  end
end
