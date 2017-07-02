# frozen_string_literal: true

namespace :mastodon do
  desc 'Execute daily tasks'
  task :daily do
    %w(
      mastodon:feeds:clear
      mastodon:media:clear
      mastodon:users:clear
      mastodon:push:refresh
    ).each do |task|
      puts "Starting #{task} at #{Time.now.utc}"
      Rake::Task[task].invoke
    end
    puts "Completed daily tasks at #{Time.now.utc}"
  end

  desc 'Turn a user into an admin, identified by the USERNAME environment variable'
  task make_admin: :environment do
    include RoutingHelper
    account_username = ENV.fetch('USERNAME')
    user = User.joins(:account).where(accounts: { username: account_username })

    if user.present?
      user.update(admin: true)
      puts "Congrats! #{account_username} is now an admin. \\o/\nNavigate to #{edit_admin_settings_url} to get started"
    else
      puts "User could not be found; please make sure an Account with the `#{account_username}` username exists."
    end
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

  desc 'Add a user by providing their email, username and initial password.' \
       'The user will receive a confirmation email, then they must reset their password before logging in.'
  task add_user: :environment do
    print 'Enter email: '
    email = STDIN.gets.chomp

    print 'Enter username: '
    username = STDIN.gets.chomp

    print 'Create user and send them confirmation mail [y/N]: '
    confirm = STDIN.gets.chomp
    puts

    if confirm.casecmp?('y')
      password = SecureRandom.hex
      user = User.new(email: email, password: password, account_attributes: { username: username })
      if user.save
        puts 'User added and confirmation mail sent to user\'s email address.'
        puts "Here is the random password generated for the user: #{password}"
      else
        puts 'Following errors occured while creating new user:'
        user.errors.each do |key, val|
          puts "#{key}: #{val}"
        end
      end
    else
      puts 'Aborted by user.'
    end
    puts
  end

  namespace :media do
    desc 'Removes media attachments that have not been assigned to any status for longer than a day'
    task clear: :environment do
      # No-op
      # This task is now executed via sidekiq-scheduler
    end

    desc 'Remove media attachments attributed to silenced accounts'
    task remove_silenced: :environment do
      MediaAttachment.where(account: Account.silenced).find_each(&:destroy)
    end

    desc 'Remove cached remote media attachments that are older than a week'
    task remove_remote: :environment do
      MediaAttachment.where.not(remote_url: '').where('created_at < ?', 1.week.ago).find_each do |media|
        media.file.destroy
        media.type = :unknown
        media.save
      end
    end

    desc 'Set unknown attachment type for remote-only attachments'
    task set_unknown: :environment do
      Rails.logger.debug 'Setting unknown attachment type for remote-only attachments...'
      MediaAttachment.where(file_file_name: nil).where.not(type: :unknown).in_batches.update_all(type: :unknown)
      Rails.logger.debug 'Done!'
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
      # No-op
      # This task is now executed via sidekiq-scheduler
    end
  end

  namespace :feeds do
    desc 'Clear timelines of inactive users'
    task clear: :environment do
      # No-op
      # This task is now executed via sidekiq-scheduler
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

    desc 'List all admin users'
    task admins: :environment do
      puts 'Admin user emails:'
      puts User.admins.map(&:email).join("\n")
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

    desc 'Ensure referencial integrity'
    task prepare_for_foreign_keys: :environment do
      # All the deletes:
      ActiveRecord::Base.connection.execute('DELETE FROM statuses USING statuses s LEFT JOIN accounts a ON a.id = s.account_id WHERE statuses.id = s.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM account_domain_blocks USING account_domain_blocks adb LEFT JOIN accounts a ON a.id = adb.account_id WHERE account_domain_blocks.id = adb.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM conversation_mutes USING conversation_mutes cm LEFT JOIN accounts a ON a.id = cm.account_id WHERE conversation_mutes.id = cm.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM conversation_mutes USING conversation_mutes cm LEFT JOIN conversations c ON c.id = cm.conversation_id WHERE conversation_mutes.id = cm.id AND c.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM favourites USING favourites f LEFT JOIN accounts a ON a.id = f.account_id WHERE favourites.id = f.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM favourites USING favourites f LEFT JOIN statuses s ON s.id = f.status_id WHERE favourites.id = f.id AND s.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM blocks USING blocks b LEFT JOIN accounts a ON a.id = b.account_id WHERE blocks.id = b.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM blocks USING blocks b LEFT JOIN accounts a ON a.id = b.target_account_id WHERE blocks.id = b.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM follow_requests USING follow_requests fr LEFT JOIN accounts a ON a.id = fr.account_id WHERE follow_requests.id = fr.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM follow_requests USING follow_requests fr LEFT JOIN accounts a ON a.id = fr.target_account_id WHERE follow_requests.id = fr.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM follows USING follows f LEFT JOIN accounts a ON a.id = f.account_id WHERE follows.id = f.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM follows USING follows f LEFT JOIN accounts a ON a.id = f.target_account_id WHERE follows.id = f.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM mutes USING mutes m LEFT JOIN accounts a ON a.id = m.account_id WHERE mutes.id = m.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM mutes USING mutes m LEFT JOIN accounts a ON a.id = m.target_account_id WHERE mutes.id = m.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM imports USING imports i LEFT JOIN accounts a ON a.id = i.account_id WHERE imports.id = i.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM mentions USING mentions m LEFT JOIN accounts a ON a.id = m.account_id WHERE mentions.id = m.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM mentions USING mentions m LEFT JOIN statuses s ON s.id = m.status_id WHERE mentions.id = m.id AND s.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM notifications USING notifications n LEFT JOIN accounts a ON a.id = n.account_id WHERE notifications.id = n.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM notifications USING notifications n LEFT JOIN accounts a ON a.id = n.from_account_id WHERE notifications.id = n.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM preview_cards USING preview_cards pc LEFT JOIN statuses s ON s.id = pc.status_id WHERE preview_cards.id = pc.id AND s.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM reports USING reports r LEFT JOIN accounts a ON a.id = r.account_id WHERE reports.id = r.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM reports USING reports r LEFT JOIN accounts a ON a.id = r.target_account_id WHERE reports.id = r.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM statuses_tags USING statuses_tags st LEFT JOIN statuses s ON s.id = st.status_id WHERE statuses_tags.tag_id = st.tag_id AND statuses_tags.status_id = st.status_id AND s.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM statuses_tags USING statuses_tags st LEFT JOIN tags t ON t.id = st.tag_id WHERE statuses_tags.tag_id = st.tag_id AND statuses_tags.status_id = st.status_id AND t.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM stream_entries USING stream_entries se LEFT JOIN accounts a ON a.id = se.account_id WHERE stream_entries.id = se.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM subscriptions USING subscriptions s LEFT JOIN accounts a ON a.id = s.account_id WHERE subscriptions.id = s.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM users USING users u LEFT JOIN accounts a ON a.id = u.account_id WHERE users.id = u.id AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM web_settings USING web_settings ws LEFT JOIN users u ON u.id = ws.user_id WHERE web_settings.id = ws.id AND u.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM oauth_access_grants USING oauth_access_grants oag LEFT JOIN users u ON u.id = oag.resource_owner_id WHERE oauth_access_grants.id = oag.id AND oag.resource_owner_id IS NOT NULL AND u.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM oauth_access_grants USING oauth_access_grants oag LEFT JOIN oauth_applications a ON a.id = oag.application_id WHERE oauth_access_grants.id = oag.id AND oag.application_id IS NOT NULL AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM oauth_access_tokens USING oauth_access_tokens oat LEFT JOIN users u ON u.id = oat.resource_owner_id WHERE oauth_access_tokens.id = oat.id AND oat.resource_owner_id IS NOT NULL AND u.id IS NULL')
      ActiveRecord::Base.connection.execute('DELETE FROM oauth_access_tokens USING oauth_access_tokens oat LEFT JOIN oauth_applications a ON a.id = oat.application_id WHERE oauth_access_tokens.id = oat.id AND oat.application_id IS NOT NULL AND a.id IS NULL')

      # All the nullifies:
      ActiveRecord::Base.connection.execute('UPDATE statuses SET in_reply_to_id = NULL FROM statuses s LEFT JOIN statuses rs ON rs.id = s.in_reply_to_id WHERE statuses.id = s.id AND s.in_reply_to_id IS NOT NULL AND rs.id IS NULL')
      ActiveRecord::Base.connection.execute('UPDATE statuses SET in_reply_to_account_id = NULL FROM statuses s LEFT JOIN accounts a ON a.id = s.in_reply_to_account_id WHERE statuses.id = s.id AND s.in_reply_to_account_id IS NOT NULL AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('UPDATE media_attachments SET status_id = NULL FROM media_attachments ma LEFT JOIN statuses s ON s.id = ma.status_id WHERE media_attachments.id = ma.id AND ma.status_id IS NOT NULL AND s.id IS NULL')
      ActiveRecord::Base.connection.execute('UPDATE media_attachments SET account_id = NULL FROM media_attachments ma LEFT JOIN accounts a ON a.id = ma.account_id WHERE media_attachments.id = ma.id AND ma.account_id IS NOT NULL AND a.id IS NULL')
      ActiveRecord::Base.connection.execute('UPDATE reports SET action_taken_by_account_id = NULL FROM reports r LEFT JOIN accounts a ON a.id = r.action_taken_by_account_id WHERE reports.id = r.id AND r.action_taken_by_account_id IS NOT NULL AND a.id IS NULL')
    end
  end
end
