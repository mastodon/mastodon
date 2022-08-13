# frozen_string_literal: true

require 'tty-prompt'

namespace :mastodon do
  desc 'Configure the instance for production use'
  task :setup do
    prompt = TTY::Prompt.new
    env    = {}

    # When the application code gets loaded, it runs `lib/mastodon/redis_configuration.rb`.
    # This happens before application environment configuration and sets REDIS_URL etc.
    # These variables are then used even when REDIS_HOST etc. are changed, so clear them
    # out so they don't interfer with our new configuration.
    ENV.delete('REDIS_URL')
    ENV.delete('CACHE_REDIS_URL')
    ENV.delete('SIDEKIQ_REDIS_URL')

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
        case prompt.select('Provider', ['Amazon S3', 'Wasabi', 'Minio', 'Google Cloud Storage'])
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
        when 'Google Cloud Storage'
          env['S3_ENABLED']             = 'true'
          env['S3_PROTOCOL']            = 'https'
          env['S3_HOSTNAME']            = 'storage.googleapis.com'
          env['S3_ENDPOINT']            = 'https://storage.googleapis.com'
          env['S3_MULTIPART_THRESHOLD'] = 50.megabytes

          env['S3_BUCKET'] = prompt.ask('GCS bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['S3_REGION'] = prompt.ask('GCS region:') do |q|
            q.required true
            q.default 'us-west1'
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('GCS access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('GCS secret key:') do |q|
            q.required true
            q.modify :strip
          end
        end

        if prompt.yes?('Do you want to access the uploaded files from your own domain?')
          env['S3_ALIAS_HOST'] = prompt.ask('Domain for uploaded files:') do |q|
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
            port:                 env['SMTP_PORT'],
            address:              env['SMTP_SERVER'],
            user_name:            env['SMTP_LOGIN'].presence,
            password:             env['SMTP_PASSWORD'].presence,
            domain:               env['LOCAL_DOMAIN'],
            authentication:       env['SMTP_AUTH_METHOD'] == 'none' ? nil : env['SMTP_AUTH_METHOD'] || :plain,
            openssl_verify_mode:  env['SMTP_OPENSSL_VERIFY_MODE'],
            enable_starttls_auto: true,
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
        incompatible_syntax = false

        env_contents = env.each_pair.map do |key, value|
          if value.is_a?(String) && value =~ /[\s\#\\"]/
            incompatible_syntax = true

            if value =~ /[']/
              value = value.to_s.gsub(/[\\"\$]/) { |x| "\\#{x}" }
              "#{key}=\"#{value}\""
            else
              "#{key}='#{value}'"
            end
          else
            "#{key}=#{value}"
          end
        end.join("\n")

        generated_header = "# Generated with mastodon:setup on #{Time.now.utc}\n\n".dup

        if incompatible_syntax
          generated_header << "# Some variables in this file will be interpreted differently whether you are\n"
          generated_header << "# using docker-compose or not.\n\n"
        end

        File.write(Rails.root.join('.env.production'), "#{generated_header}#{env_contents}\n")

        if using_docker
          prompt.ok 'Below is your configuration, save it to an .env.production file outside Docker:'
          prompt.say "\n"
          prompt.say "#{generated_header}#{env.each_pair.map { |key, value| "#{key}=#{value}" }.join("\n")}"
          prompt.say "\n"
          prompt.ok 'It is also saved within this container so you can proceed with this wizard.'
        end

        prompt.say "\n"
        prompt.say 'Now that configuration is saved, the database schema must be loaded.'
        prompt.warn 'If the database already exists, this will erase its contents.'

        if prompt.yes?('Prepare the database now?')
          prompt.say 'Running `RAILS_ENV=production rails db:setup` ...'
          prompt.say "\n\n"

          if !system(env.transform_values(&:to_s).merge({ 'RAILS_ENV' => 'production', 'SAFETY_ASSURED' => '1' }), 'rails db:setup')
            prompt.error 'That failed! Perhaps your configuration is not right'
          else
            prompt.ok 'Done!'
          end
        end

        unless using_docker
          prompt.say "\n"
          prompt.say 'The final step is compiling CSS/JS assets.'
          prompt.say 'This may take a while and consume a lot of RAM.'

          if prompt.yes?('Compile the assets now?')
            prompt.say 'Running `RAILS_ENV=production rails assets:precompile` ...'
            prompt.say "\n\n"

            if !system(env.transform_values(&:to_s).merge({ 'RAILS_ENV' => 'production' }), 'rails assets:precompile')
              prompt.error 'That failed! Maybe you need swap space?'
            else
              prompt.say 'Done!'
            end
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

          user = User.new(admin: true, email: email, password: password, confirmed_at: Time.now.utc, account_attributes: { username: username }, bypass_invite_request_check: true)
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

  namespace :webpush do
    desc 'Generate VAPID key'
    task :generate_vapid_key do
      vapid_key = Webpush.generate_key
      puts "VAPID_PRIVATE_KEY=#{vapid_key.private_key}"
      puts "VAPID_PUBLIC_KEY=#{vapid_key.public_key}"
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
