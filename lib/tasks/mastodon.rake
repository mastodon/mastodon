# frozen_string_literal: true

require 'optparse'
require 'colorize'
require 'tty-command'
require 'tty-prompt'

namespace :mastodon do
  desc 'Configure the instance for production use'
  task :setup do
    prompt = TTY::Prompt.new
    env    = {}

    begin
      prompt.say('Your instance is identified by its domain name. Changing it afterward will break things.')
      env['LOCAL_DOMAIN'] = prompt.ask('Domain name:') do |q|
        q.required true
        q.modify :strip
        q.validate(/\A[a-z0-9\.\-]+\z/i)
        q.messages[:valid?] = 'Invalid domain. If you intend to use unicode characters, enter punycode here'
      end

      prompt.say "\n"

      prompt.say('Single user mode disables registrations and redirects the landing page to your public profile.')
      env['SINGLE_USER_MODE'] = prompt.yes?('Do you want to enable single user mode?', default: false)

      %w(SECRET_KEY_BASE OTP_SECRET).each do |key|
        env[key] = SecureRandom.hex(64)
      end

      vapid_key = Webpush.generate_key

      env['VAPID_PRIVATE_KEY'] = vapid_key.private_key
      env['VAPID_PUBLIC_KEY']  = vapid_key.public_key

      prompt.say "\n"

      using_docker        = prompt.yes?('Are you using Docker to run Mastodon?')
      db_connection_works = false

      prompt.say "\n"

      loop do
        env['DB_HOST'] = prompt.ask('PostgreSQL host:') do |q|
          q.required true
          q.default using_docker ? 'db' : '/var/run/postgresql'
          q.modify :strip
        end

        env['DB_PORT'] = prompt.ask('PostgreSQL port:') do |q|
          q.required true
          q.default 5432
          q.convert :int
        end

        env['DB_NAME'] = prompt.ask('Name of PostgreSQL database:') do |q|
          q.required true
          q.default using_docker ? 'postgres' : 'mastodon_production'
          q.modify :strip
        end

        env['DB_USER'] = prompt.ask('Name of PostgreSQL user:') do |q|
          q.required true
          q.default using_docker ? 'postgres' : 'mastodon'
          q.modify :strip
        end

        env['DB_PASS'] = prompt.ask('Password of PostgreSQL user:') do |q|
          q.echo false
        end

        # The chosen database may not exist yet. Connect to default database
        # to avoid "database does not exist" error.
        db_options = {
          adapter: :postgresql,
          database: 'postgres',
          host: env['DB_HOST'],
          port: env['DB_PORT'],
          user: env['DB_USER'],
          password: env['DB_PASS'],
        }

        begin
          ActiveRecord::Base.establish_connection(db_options)
          ActiveRecord::Base.connection
          prompt.ok 'Database configuration works! 🎆'
          db_connection_works = true
          break
        rescue StandardError => e
          prompt.error 'Database connection could not be established with this configuration, try again.'
          prompt.error e.message
          break unless prompt.yes?('Try again?')
        end
      end

      prompt.say "\n"

      loop do
        env['REDIS_HOST'] = prompt.ask('Redis host:') do |q|
          q.required true
          q.default using_docker ? 'redis' : 'localhost'
          q.modify :strip
        end

        env['REDIS_PORT'] = prompt.ask('Redis port:') do |q|
          q.required true
          q.default 6379
          q.convert :int
        end

        env['REDIS_PASSWORD'] = prompt.ask('Redis password:') do |q|
          q.required false
          q.default nil
          q.modify :strip
        end

        redis_options = {
          host: env['REDIS_HOST'],
          port: env['REDIS_PORT'],
          password: env['REDIS_PASSWORD'],
          driver: :hiredis,
        }

        begin
          redis = Redis.new(redis_options)
          redis.ping
          prompt.ok 'Redis configuration works! 🎆'
          break
        rescue StandardError => e
          prompt.error 'Redis connection could not be established with this configuration, try again.'
          prompt.error e.message
          break unless prompt.yes?('Try again?')
        end
      end

      prompt.say "\n"

      if prompt.yes?('Do you want to store uploaded files on the cloud?', default: false)
        case prompt.select('Provider', ['Amazon S3', 'Wasabi', 'Minio'])
        when 'Amazon S3'
          env['S3_ENABLED']  = 'true'
          env['S3_PROTOCOL'] = 'https'

          env['S3_BUCKET'] = prompt.ask('S3 bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['S3_REGION'] = prompt.ask('S3 region:') do |q|
            q.required true
            q.default 'us-east-1'
            q.modify :strip
          end

          env['S3_HOSTNAME'] = prompt.ask('S3 hostname:') do |q|
            q.required true
            q.default 's3-us-east-1.amazonaws.com'
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('S3 access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('S3 secret key:') do |q|
            q.required true
            q.modify :strip
          end
        when 'Wasabi'
          env['S3_ENABLED']  = 'true'
          env['S3_PROTOCOL'] = 'https'
          env['S3_REGION']   = 'us-east-1'
          env['S3_HOSTNAME'] = 's3.wasabisys.com'
          env['S3_ENDPOINT'] = 'https://s3.wasabisys.com/'

          env['S3_BUCKET'] = prompt.ask('Wasabi bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('Wasabi access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('Wasabi secret key:') do |q|
            q.required true
            q.modify :strip
          end
        when 'Minio'
          env['S3_ENABLED']  = 'true'
          env['S3_PROTOCOL'] = 'https'
          env['S3_REGION']   = 'us-east-1'

          env['S3_ENDPOINT'] = prompt.ask('Minio endpoint URL:') do |q|
            q.required true
            q.modify :strip
          end

          env['S3_PROTOCOL'] = env['S3_ENDPOINT'].start_with?('https') ? 'https' : 'http'
          env['S3_HOSTNAME'] = env['S3_ENDPOINT'].gsub(/\Ahttps?:\/\//, '')

          env['S3_BUCKET'] = prompt.ask('Minio bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('Minio access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('Minio secret key:') do |q|
            q.required true
            q.modify :strip
          end
        end

        if prompt.yes?('Do you want to access the uploaded files from your own domain?')
          env['S3_CLOUDFRONT_HOST'] = prompt.ask('Domain for uploaded files:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end
        end
      end

      prompt.say "\n"

      loop do
        if prompt.yes?('Do you want to send e-mails from localhost?', default: false)
          env['SMTP_SERVER'] = 'localhost'
          env['SMTP_PORT'] = 25
          env['SMTP_AUTH_METHOD'] = 'none'
          env['SMTP_OPENSSL_VERIFY_MODE'] = 'none'
        else
          env['SMTP_SERVER'] = prompt.ask('SMTP server:') do |q|
            q.required true
            q.default 'smtp.mailgun.org'
            q.modify :strip
          end

          env['SMTP_PORT'] = prompt.ask('SMTP port:') do |q|
            q.required true
            q.default 587
            q.convert :int
          end

          env['SMTP_LOGIN'] = prompt.ask('SMTP username:') do |q|
            q.modify :strip
          end

          env['SMTP_PASSWORD'] = prompt.ask('SMTP password:') do |q|
            q.echo false
          end

          env['SMTP_AUTH_METHOD'] = prompt.ask('SMTP authentication:') do |q|
            q.required
            q.default 'plain'
            q.modify :strip
          end

          env['SMTP_OPENSSL_VERIFY_MODE'] = prompt.select('SMTP OpenSSL verify mode:', %w(none peer client_once fail_if_no_peer_cert))
        end

        env['SMTP_FROM_ADDRESS'] = prompt.ask('E-mail address to send e-mails "from":') do |q|
          q.required true
          q.default "Mastodon <notifications@#{env['LOCAL_DOMAIN']}>"
          q.modify :strip
        end

        break unless prompt.yes?('Send a test e-mail with this configuration right now?')

        send_to = prompt.ask('Send test e-mail to:', required: true)

        begin
          ActionMailer::Base.smtp_settings = {
            :port                 => env['SMTP_PORT'],
            :address              => env['SMTP_SERVER'],
            :user_name            => env['SMTP_LOGIN'].presence,
            :password             => env['SMTP_PASSWORD'].presence,
            :domain               => env['LOCAL_DOMAIN'],
            :authentication       => env['SMTP_AUTH_METHOD'] == 'none' ? nil : env['SMTP_AUTH_METHOD'] || :plain,
            :openssl_verify_mode  => env['SMTP_OPENSSL_VERIFY_MODE'],
            :enable_starttls_auto => true,
          }

          ActionMailer::Base.default_options = {
            from: env['SMTP_FROM_ADDRESS'],
          }

          mail = ActionMailer::Base.new.mail to: send_to, subject: 'Test', body: 'Mastodon SMTP configuration works!'
          mail.deliver
          break
        rescue StandardError => e
          prompt.error 'E-mail could not be sent with this configuration, try again.'
          prompt.error e.message
          break unless prompt.yes?('Try again?')
        end
      end

      prompt.say "\n"
      prompt.say 'This configuration will be written to .env.production'

      if prompt.yes?('Save configuration?')
        cmd = TTY::Command.new(printer: :quiet)

        File.write(Rails.root.join('.env.production'), "# Generated with mastodon:setup on #{Time.now.utc}\n\n" + env.each_pair.map { |key, value| "#{key}=#{value}" }.join("\n") + "\n")

        if using_docker
          prompt.ok 'Below is your configuration, save it to an .env.production file outside Docker:'
          prompt.say "\n"
          prompt.say File.read(Rails.root.join('.env.production'))
          prompt.say "\n"
          prompt.ok 'It is also saved within this container so you can proceed with this wizard.'
        end

        prompt.say "\n"
        prompt.say 'Now that configuration is saved, the database schema must be loaded.'
        prompt.warn 'If the database already exists, this will erase its contents.'

        if prompt.yes?('Prepare the database now?')
          prompt.say 'Running `RAILS_ENV=production rails db:setup` ...'
          prompt.say "\n"

          if cmd.run!({ RAILS_ENV: 'production', SAFETY_ASSURED: 1 }, :rails, 'db:setup').failure?
            prompt.say "\n"
            prompt.error 'That failed! Perhaps your configuration is not right'
          else
            prompt.say "\n"
            prompt.ok 'Done!'
          end
        end

        prompt.say "\n"
        prompt.say 'The final step is compiling CSS/JS assets.'
        prompt.say 'This may take a while and consume a lot of RAM.'

        if prompt.yes?('Compile the assets now?')
          prompt.say 'Running `RAILS_ENV=production rails assets:precompile` ...'
          prompt.say "\n"

          if cmd.run!({ RAILS_ENV: 'production' }, :rails, 'assets:precompile').failure?
            prompt.say "\n"
            prompt.error 'That failed! Maybe you need swap space?'
          else
            prompt.say "\n"
            prompt.say 'Done!'
          end
        end

        prompt.say "\n"
        prompt.ok 'All done! You can now power on the Mastodon server 🐘'
        prompt.say "\n"

        if db_connection_works && prompt.yes?('Do you want to create an admin user straight away?')
          env.each_pair do |key, value|
            ENV[key] = value.to_s
          end

          require_relative '../../config/environment'
          disable_log_stdout!

          username = prompt.ask('Username:') do |q|
            q.required true
            q.default 'admin'
            q.validate(/\A[a-z0-9_]+\z/i)
            q.modify :strip
          end

          email = prompt.ask('E-mail:') do |q|
            q.required true
            q.modify :strip
          end

          password = SecureRandom.hex(16)

          user = User.new(admin: true, email: email, password: password, confirmed_at: Time.now.utc, account_attributes: { username: username })
          user.save(validate: false)

          prompt.ok "You can login with the password: #{password}"
          prompt.warn 'You can change your password once you login.'
        end
      else
        prompt.warn 'Nothing saved. Bye!'
      end
    rescue TTY::Reader::InputInterrupt
      prompt.ok 'Aborting. Bye!'
    end
  end

  desc 'Execute daily tasks (deprecated)'
  task :daily do
    # No-op
    # All of these tasks are now executed via sidekiq-scheduler
  end

  desc 'Turn a user into an admin, identified by the USERNAME environment variable'
  task make_admin: :environment do
    include RoutingHelper

    account_username = ENV.fetch('USERNAME')
    user             = User.joins(:account).where(accounts: { username: account_username })

    if user.present?
      user.update(admin: true)
      puts "Congrats! #{account_username} is now an admin. \\o/\nNavigate to #{edit_admin_settings_url} to get started"
    else
      puts "User could not be found; please make sure an account with the `#{account_username}` username exists."
    end
  end

  desc 'Turn a user into a moderator, identified by the USERNAME environment variable'
  task make_mod: :environment do
    account_username = ENV.fetch('USERNAME')
    user             = User.joins(:account).where(accounts: { username: account_username })

    if user.present?
      user.update(moderator: true)
      puts "Congrats! #{account_username} is now a moderator \\o/"
    else
      puts "User could not be found; please make sure an account with the `#{account_username}` username exists."
    end
  end

  desc 'Remove admin and moderator privileges from user identified by the USERNAME environment variable'
  task revoke_staff: :environment do
    account_username = ENV.fetch('USERNAME')
    user             = User.joins(:account).where(accounts: { username: account_username })

    if user.present?
      user.update(moderator: false, admin: false)
      puts "#{account_username} is no longer admin or moderator."
    else
      puts "User could not be found; please make sure an account with the `#{account_username}` username exists."
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
    disable_log_stdout!

    prompt = TTY::Prompt.new

    begin
      email = prompt.ask('E-mail:', required: true) do |q|
        q.modify :strip
      end

      username = prompt.ask('Username:', required: true) do |q|
        q.modify :strip
      end

      role = prompt.select('Role:', %w(user moderator admin))

      if prompt.yes?('Proceed to create the user?')
        user = User.new(email: email, password: SecureRandom.hex, admin: role == 'admin', moderator: role == 'moderator', account_attributes: { username: username })

        if user.save
          prompt.ok 'User created and confirmation mail sent to the user\'s email address.'
          prompt.ok "Here is the random password generated for the user: #{user.password}"
        else
          prompt.warn 'User was not created because of the following errors:'

          user.errors.each do |key, val|
            prompt.error "#{key}: #{val}"
          end
        end
      else
        prompt.ok 'Aborting. Bye!'
      end
    rescue TTY::Reader::InputInterrupt
      prompt.ok 'Aborting. Bye!'
    end
  end

  namespace :media do
    desc 'Removes media attachments that have not been assigned to any status for longer than a day (deprecated)'
    task clear: :environment do
      # No-op
      # This task is now executed via sidekiq-scheduler
    end

    desc 'Remove media attachments attributed to silenced accounts'
    task remove_silenced: :environment do
      MediaAttachment.where(account: Account.silenced).select(:id).find_in_batches do |media_attachments|
        Maintenance::DestroyMediaWorker.push_bulk(media_attachments.map(&:id))
      end
    end

    desc 'Remove cached remote media attachments that are older than NUM_DAYS. By default 7 (week)'
    task remove_remote: :environment do
      time_ago = ENV.fetch('NUM_DAYS') { 7 }.to_i.days.ago

      MediaAttachment.where.not(remote_url: '').where.not(file_file_name: nil).where('created_at < ?', time_ago).select(:id).find_in_batches do |media_attachments|
        Maintenance::UncacheMediaWorker.push_bulk(media_attachments.map(&:id))
      end
    end

    desc 'Set unknown attachment type for remote-only attachments'
    task set_unknown: :environment do
      puts 'Setting unknown attachment type for remote-only attachments...'
      MediaAttachment.where(file_file_name: nil).where.not(type: :unknown).in_batches.update_all(type: :unknown)
      puts 'Done!'
    end

    desc 'Redownload avatars/headers of remote users. Optionally limit to a particular domain with DOMAIN'
    task redownload_avatars: :environment do
      accounts = Account.remote
      accounts = accounts.where(domain: ENV['DOMAIN']) if ENV['DOMAIN'].present?

      accounts.select(:id).find_in_batches do |accounts_batch|
        Maintenance::RedownloadAccountMediaWorker.push_bulk(accounts_batch.map(&:id))
      end
    end
  end

  namespace :push do
    desc 'Unsubscribes from PuSH updates of feeds nobody follows locally'
    task clear: :environment do
      Pubsubhubbub::UnsubscribeWorker.push_bulk(Account.remote.without_followers.where.not(subscription_expires_at: nil).pluck(:id))
    end

    desc 'Re-subscribes to soon expiring PuSH subscriptions (deprecated)'
    task refresh: :environment do
      # No-op
      # This task is now executed via sidekiq-scheduler
    end
  end

  namespace :feeds do
    desc 'Clear timelines of inactive users (deprecated)'
    task clear: :environment do
      # No-op
      # This task is now executed via sidekiq-scheduler
    end

    desc 'Clear all timelines without regenerating them'
    task clear_all: :environment do
      Redis.current.keys('feed:*').each { |key| Redis.current.del(key) }
    end

    desc 'Generates home timelines for users who logged in in the past two weeks'
    task build: :environment do
      User.active.select(:id, :account_id).find_in_batches do |users|
        RegenerationWorker.push_bulk(users.map(&:account_id))
      end
    end
  end

  namespace :emails do
    desc 'Send out digest e-mails (deprecated)'
    task digest: :environment do
      # No-op
      # This task is now executed via sidekiq-scheduler
    end
  end

  namespace :users do
    desc 'Clear out unconfirmed users (deprecated)'
    task clear: :environment do
      # No-op
      # This task is now executed via sidekiq-scheduler
    end

    desc 'List e-mails of all admin users'
    task admins: :environment do
      puts 'Admin user emails:'
      puts User.admins.map(&:email).join("\n")
    end
  end

  namespace :settings do
    desc 'Open registrations on this instance'
    task open_registrations: :environment do
      Setting.open_registrations = true
    end

    desc 'Close registrations on this instance'
    task close_registrations: :environment do
      Setting.open_registrations = false
    end
  end

  namespace :webpush do
    desc 'Generate VAPID key'
    task generate_vapid_key: :environment do
      vapid_key = Webpush.generate_key
      puts "VAPID_PRIVATE_KEY=#{vapid_key.private_key}"
      puts "VAPID_PUBLIC_KEY=#{vapid_key.public_key}"
    end
  end

  namespace :maintenance do
    desc 'Update counter caches'
    task update_counter_caches: :environment do
      puts 'Updating counter caches for accounts...'

      Account.unscoped.where.not(protocol: :activitypub).select('id').find_in_batches do |batch|
        Account.where(id: batch.map(&:id)).update_all('statuses_count = (select count(*) from statuses where account_id = accounts.id), followers_count = (select count(*) from follows where target_account_id = accounts.id), following_count = (select count(*) from follows where account_id = accounts.id)')
      end

      puts 'Updating counter caches for statuses...'

      Status.unscoped.select('id').find_in_batches do |batch|
        Status.where(id: batch.map(&:id)).update_all('favourites_count = (select count(*) from favourites where favourites.status_id = statuses.id), reblogs_count = (select count(*) from statuses as reblogs where reblogs.reblog_of_id = statuses.id)')
      end

      puts 'Done!'
    end

    desc 'Generate static versions of GIF avatars/headers'
    task add_static_avatars: :environment do
      puts 'Generating static avatars/headers for GIF ones...'

      Account.unscoped.where(avatar_content_type: 'image/gif').or(Account.unscoped.where(header_content_type: 'image/gif')).find_each do |account|
        begin
          account.avatar.reprocess! if account.avatar_content_type == 'image/gif' && !account.avatar.exists?(:static)
          account.header.reprocess! if account.header_content_type == 'image/gif' && !account.header.exists?(:static)
        rescue StandardError => e
          Rails.logger.error "Error while generating static avatars/headers for account #{account.id}: #{e}"
          next
        end
      end

      puts 'Done!'
    end

    desc 'Ensure referencial integrity'
    task prepare_for_foreign_keys: :environment do
      # All the deletes:
      ActiveRecord::Base.connection.execute('DELETE FROM statuses USING statuses s LEFT JOIN accounts a ON a.id = s.account_id WHERE statuses.id = s.id AND a.id IS NULL')

      if ActiveRecord::Base.connection.table_exists? :account_domain_blocks
        ActiveRecord::Base.connection.execute('DELETE FROM account_domain_blocks USING account_domain_blocks adb LEFT JOIN accounts a ON a.id = adb.account_id WHERE account_domain_blocks.id = adb.id AND a.id IS NULL')
      end

      if ActiveRecord::Base.connection.table_exists? :conversation_mutes
        ActiveRecord::Base.connection.execute('DELETE FROM conversation_mutes USING conversation_mutes cm LEFT JOIN accounts a ON a.id = cm.account_id WHERE conversation_mutes.id = cm.id AND a.id IS NULL')
        ActiveRecord::Base.connection.execute('DELETE FROM conversation_mutes USING conversation_mutes cm LEFT JOIN conversations c ON c.id = cm.conversation_id WHERE conversation_mutes.id = cm.id AND c.id IS NULL')
      end

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

    desc 'Remove deprecated preview cards'
    task remove_deprecated_preview_cards: :environment do
      next unless ActiveRecord::Base.connection.table_exists? 'deprecated_preview_cards'

      class DeprecatedPreviewCard < ActiveRecord::Base
        self.inheritance_column = false

        path = '/preview_cards/:attachment/:id_partition/:style/:filename'
        if ENV['S3_ENABLED'] != 'true'
          path = (ENV['PAPERCLIP_ROOT_PATH'] || ':rails_root/public/system') + path
        end

        has_attached_file :image, styles: { original: '280x120>' }, convert_options: { all: '-quality 80 -strip' }, path: path
      end

      puts 'Delete records and associated files from deprecated preview cards? [y/N]: '
      confirm = STDIN.gets.chomp

      if confirm.casecmp('y').zero?
        DeprecatedPreviewCard.in_batches.destroy_all

        puts 'Drop deprecated preview cards table? [y/N]: '
        confirm = STDIN.gets.chomp

        if confirm.casecmp('y').zero?
          ActiveRecord::Migration.drop_table :deprecated_preview_cards
        end
      end
    end

    desc 'Migrate photo preview cards made before 2.1'
    task migrate_photo_preview_cards: :environment do
      status_ids = Status.joins(:preview_cards)
                         .where(preview_cards: { embed_url: '', type: :photo })
                         .reorder(nil)
                         .group(:id)
                         .pluck(:id)

      PreviewCard.where(embed_url: '', type: :photo).delete_all
      LinkCrawlWorker.push_bulk status_ids
    end

    desc 'Find case-insensitive username duplicates of local users'
    task find_duplicate_usernames: :environment do
      include RoutingHelper

      disable_log_stdout!

      duplicate_masters = Account.find_by_sql('SELECT * FROM accounts WHERE id IN (SELECT min(id) FROM accounts WHERE domain IS NULL GROUP BY lower(username) HAVING count(*) > 1)')
      pastel = Pastel.new

      duplicate_masters.each do |account|
        puts pastel.yellow("First of their name: ") + pastel.bold(account.username) + " (#{admin_account_url(account.id)})"

        Account.where('lower(username) = ?', account.username.downcase).where.not(id: account.id).each do |duplicate|
          puts "  " + pastel.red("Duplicate: ") + admin_account_url(duplicate.id)
        end
      end
    end

    desc 'Remove all home feed regeneration markers'
    task remove_regeneration_markers: :environment do
      keys = Redis.current.keys('account:*:regeneration')

      Redis.current.pipelined do
        keys.each { |key| Redis.current.del(key) }
      end
    end

    desc 'Check every known remote account and delete those that no longer exist in origin'
    task purge_removed_accounts: :environment do
      prepare_for_options!

      options = {}

      OptionParser.new do |opts|
        opts.banner = 'Usage: rails mastodon:maintenance:purge_removed_accounts [options]'

        opts.on('-f', '--force', 'Remove all encountered accounts without asking for confirmation') do
          options[:force] = true
        end

        opts.on('-h', '--help', 'Display this message') do
          puts opts
          exit
        end
      end.parse!

      disable_log_stdout!

      total        = Account.remote.where(protocol: :activitypub).count
      progress_bar = ProgressBar.create(total: total, format: '%c/%C |%w>%i| %e')

      Account.remote.where(protocol: :activitypub).partitioned.find_each do |account|
        progress_bar.increment

        begin
          code = Request.new(:head, account.uri).perform(&:code)
        rescue StandardError
          # This could happen due to network timeout, DNS timeout, wrong SSL cert, etc,
          # which should probably not lead to perceiving the account as deleted, so
          # just skip till next time
          next
        end

        if [404, 410].include?(code)
          if options[:force]
            SuspendAccountService.new.call(account)
            account.destroy
          else
            progress_bar.pause
            progress_bar.clear
            print "\nIt seems like #{account.acct} no longer exists. Purge the account from the database? [Y/n]: ".colorize(:yellow)
            confirm = STDIN.gets.chomp
            puts ''
            progress_bar.resume

            if confirm.casecmp('n').zero?
              next
            else
              SuspendAccountService.new.call(account)
              account.destroy
            end
          end
        end
      end
    end
  end
end

def disable_log_stdout!
  dev_null = Logger.new('/dev/null')

  Rails.logger                 = dev_null
  ActiveRecord::Base.logger    = dev_null
  HttpLog.configuration.logger = dev_null
  Paperclip.options[:log]      = false
end

def prepare_for_options!
  2.times { ARGV.shift }
end
