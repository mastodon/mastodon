# frozen_string_literal: true

namespace :tests do
  namespace :migrations do
    desc 'Check that database state is consistent with a successful migration from populated data'
    task check_database: :environment do
      unless Account.find_by(username: 'admin', domain: nil)&.hide_collections? == false
        puts 'Unexpected value for Account#hide_collections? for user @admin'
        exit(1)
      end

      unless Account.find_by(username: 'user', domain: nil)&.hide_collections? == true
        puts 'Unexpected value for Account#hide_collections? for user @user'
        exit(1)
      end

      unless Account.find_by(username: 'evil', domain: 'activitypub.com')&.suspended?
        puts 'Unexpected value for Account#suspended? for user @evil@activitypub.com'
        exit(1)
      end

      unless Status.find(6).account_id == Status.find(7).account_id
        puts 'Users @remote@remote.com and @Remote@remote.com not properly merged'
        exit(1)
      end

      if Account.where(domain: Rails.configuration.x.local_domain).exists?
        puts 'Faux remote accounts not properly claned up'
        exit(1)
      end

      unless AccountConversation.first&.last_status_id == 11
        puts 'AccountConversation records not created as expected'
        exit(1)
      end

      if Account.find(-99).private_key.blank?
        puts 'Instance actor does not have a private key'
        exit(1)
      end

      unless Account.find_by(username: 'user', domain: nil).custom_filters.map { |filter| filter.keywords.pluck(:keyword) } == [['test'], ['take']]
        puts 'CustomFilterKeyword records not created as expected'
        exit(1)
      end

      unless Admin::ActionLog.find_by(target_type: 'DomainBlock', target_id: 1).human_identifier == 'example.org'
        puts 'Admin::ActionLog domain block records not updated as expected'
        exit(1)
      end

      unless Admin::ActionLog.find_by(target_type: 'EmailDomainBlock', target_id: 1).human_identifier == 'example.org'
        puts 'Admin::ActionLog email domain block records not updated as expected'
        exit(1)
      end
    end

    desc 'Populate the database with test data for 2.4.3'
    task populate_v2_4_3: :environment do # rubocop:disable Naming/VariableNumber
      ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO "custom_filters"
          (id, account_id, phrase, context, whole_word, irreversible, created_at, updated_at)
        VALUES
          (1, 2, 'test', '{ "home", "public" }', true, true, now(), now()),
          (2, 2, 'take', '{ "home" }', false, false, now(), now());

        -- Orphaned admin action logs

        INSERT INTO "admin_action_logs"
          (account_id, action, target_type, target_id, created_at, updated_at)
        VALUES
          (1, 'destroy', 'Account', 1312, now(), now()),
          (1, 'destroy', 'User', 1312, now(), now()),
          (1, 'destroy', 'Report', 1312, now(), now()),
          (1, 'destroy', 'DomainBlock', 1312, now(), now()),
          (1, 'destroy', 'EmailDomainBlock', 1312, now(), now()),
          (1, 'destroy', 'Status', 1312, now(), now()),
          (1, 'destroy', 'CustomEmoji', 1312, now(), now());

        -- Admin action logs with linked objects

        INSERT INTO "domain_blocks"
          (id, domain, created_at, updated_at)
        VALUES
          (1, 'example.org', now(), now());

        INSERT INTO "email_domain_blocks"
          (id, domain, created_at, updated_at)
        VALUES
          (1, 'example.org', now(), now());

        INSERT INTO "admin_action_logs"
          (account_id, action, target_type, target_id, created_at, updated_at)
        VALUES
          (1, 'destroy', 'Account', 1, now(), now()),
          (1, 'destroy', 'User', 1, now(), now()),
          (1, 'destroy', 'DomainBlock', 1, now(), now()),
          (1, 'destroy', 'EmailDomainBlock', 1, now(), now()),
          (1, 'destroy', 'Status', 1, now(), now()),
          (1, 'destroy', 'CustomEmoji', 3, now(), now());
      SQL
    end

    desc 'Populate the database with test data for 2.4.0'
    task populate_v2_4: :environment do # rubocop:disable Naming/VariableNumber
      ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO "settings"
          (id, thing_type, thing_id, var, value, created_at, updated_at)
        VALUES
          (1, 'User', 1, 'hide_network', E'--- false\n', now(), now()),
          (2, 'User', 2, 'hide_network', E'--- true\n', now(), now());
      SQL
    end

    desc 'Populate the database with test data for 2.0.0'
    task populate_v2: :environment do
      admin_key   = OpenSSL::PKey::RSA.new(2048)
      user_key    = OpenSSL::PKey::RSA.new(2048)
      remote_key  = OpenSSL::PKey::RSA.new(2048)
      remote_key2 = OpenSSL::PKey::RSA.new(2048)
      remote_key3 = OpenSSL::PKey::RSA.new(2048)
      admin_private_key    = ActiveRecord::Base.connection.quote(admin_key.to_pem)
      admin_public_key     = ActiveRecord::Base.connection.quote(admin_key.public_key.to_pem)
      user_private_key     = ActiveRecord::Base.connection.quote(user_key.to_pem)
      user_public_key      = ActiveRecord::Base.connection.quote(user_key.public_key.to_pem)
      remote_public_key    = ActiveRecord::Base.connection.quote(remote_key.public_key.to_pem)
      remote_public_key2   = ActiveRecord::Base.connection.quote(remote_key2.public_key.to_pem)
      remote_public_key_ap = ActiveRecord::Base.connection.quote(remote_key3.public_key.to_pem)
      local_domain = ActiveRecord::Base.connection.quote(Rails.configuration.x.local_domain)

      ActiveRecord::Base.connection.execute(<<~SQL)
        -- accounts

        INSERT INTO "accounts"
          (id, username, domain, private_key, public_key, created_at, updated_at)
        VALUES
          (1, 'admin', NULL, #{admin_private_key}, #{admin_public_key}, now(), now()),
          (2, 'user',  NULL, #{user_private_key},  #{user_public_key},  now(), now());

        INSERT INTO "accounts"
          (id, username, domain, private_key, public_key, created_at, updated_at, remote_url, salmon_url)
        VALUES
          (3, 'remote', 'remote.com', NULL, #{remote_public_key}, now(), now(),
           'https://remote.com/@remote', 'https://remote.com/salmon/1'),
          (4, 'Remote', 'remote.com', NULL, #{remote_public_key}, now(), now(),
           'https://remote.com/@Remote', 'https://remote.com/salmon/1'),
          (5, 'REMOTE', 'Remote.com', NULL, #{remote_public_key2}, now() - interval '1 year', now() - interval '1 year',
           'https://remote.com/stale/@REMOTE', 'https://remote.com/stale/salmon/1');

        INSERT INTO "accounts"
          (id, username, domain, private_key, public_key, created_at, updated_at, protocol, inbox_url, outbox_url, followers_url)
        VALUES
          (6, 'bob', 'activitypub.com', NULL, #{remote_public_key_ap}, now(), now(),
           1, 'https://activitypub.com/users/bob/inbox', 'https://activitypub.com/users/bob/outbox', 'https://activitypub.com/users/bob/followers');

        INSERT INTO "accounts"
          (id, username, domain, private_key, public_key, created_at, updated_at)
        VALUES
          (7, 'user', #{local_domain}, #{user_private_key}, #{user_public_key}, now(), now()),
          (8, 'pt_user', NULL, #{user_private_key}, #{user_public_key}, now(), now());

        INSERT INTO "accounts"
          (id, username, domain, private_key, public_key, created_at, updated_at, protocol, inbox_url, outbox_url, followers_url, suspended)
        VALUES
          (9, 'evil', 'activitypub.com', NULL, #{remote_public_key_ap}, now(), now(),
           1, 'https://activitypub.com/users/evil/inbox', 'https://activitypub.com/users/evil/outbox',
           'https://activitypub.com/users/evil/followers', true);

        -- users

        INSERT INTO "users"
          (id, account_id, email, created_at, updated_at, admin)
        VALUES
          (1, 1, 'admin@localhost', now(), now(), true),
          (2, 2, 'user@localhost', now(), now(), false);

        INSERT INTO "users"
          (id, account_id, email, created_at, updated_at, admin, locale)
        VALUES
          (3, 7, 'ptuser@localhost', now(), now(), false, 'pt');

        -- conversations
        INSERT INTO "conversations" (id, created_at, updated_at) VALUES (1, now(), now());

        -- statuses

        INSERT INTO "statuses"
          (id, account_id, text, created_at, updated_at)
        VALUES
          (1, 1, 'test', now(), now()),
          (2, 1, '@remote@remote.com hello', now(), now()),
          (3, 1, '@Remote@remote.com hello', now(), now()),
          (4, 1, '@REMOTE@remote.com hello', now(), now());

        INSERT INTO "statuses"
          (id, account_id, text, created_at, updated_at, uri, local)
        VALUES
          (5, 1, 'activitypub status', now(), now(), 'https://localhost/users/admin/statuses/4', true);

        INSERT INTO "statuses"
          (id, account_id, text, created_at, updated_at)
        VALUES
          (6, 3, 'test', now(), now());

        INSERT INTO "statuses"
          (id, account_id, text, created_at, updated_at, in_reply_to_id, in_reply_to_account_id)
        VALUES
          (7, 4, '@admin hello', now(), now(), 3, 1);

        INSERT INTO "statuses"
          (id, account_id, text, created_at, updated_at)
        VALUES
          (8, 5, 'test', now(), now());

        INSERT INTO "statuses"
          (id, account_id, reblog_of_id, created_at, updated_at)
        VALUES
          (9, 1, 2, now(), now());

        INSERT INTO "statuses"
          (id, account_id, text, in_reply_to_id, conversation_id, visibility, created_at, updated_at)
        VALUES
          (10, 2, '@admin hey!', NULL, 1, 3, now(), now()),
          (11, 1, '@user hey!', 10, 1, 3, now(), now());

        -- mentions (from previous statuses)

        INSERT INTO "mentions"
          (id, status_id, account_id, created_at, updated_at)
        VALUES
          (1, 2, 3, now(), now()),
          (2, 3, 4, now(), now()),
          (3, 4, 5, now(), now()),
          (4, 10, 1, now(), now()),
          (5, 11, 2, now(), now());

        -- stream entries

        INSERT INTO "stream_entries"
          (activity_id, account_id, activity_type, created_at, updated_at)
        VALUES
          (1, 1, 'status', now(), now()),
          (2, 1, 'status', now(), now()),
          (3, 1, 'status', now(), now()),
          (4, 1, 'status', now(), now()),
          (5, 1, 'status', now(), now()),
          (6, 3, 'status', now(), now()),
          (7, 4, 'status', now(), now()),
          (8, 5, 'status', now(), now()),
          (9, 1, 'status', now(), now());

        -- custom emoji

        INSERT INTO "custom_emojis"
          (id, shortcode, created_at, updated_at)
        VALUES
          (1, 'test', now(), now()),
          (2, 'Test', now(), now()),
          (3, 'blobcat', now(), now());

        INSERT INTO "custom_emojis"
          (id, shortcode, domain, uri, created_at, updated_at)
        VALUES
          (4, 'blobcat', 'remote.org', 'https://remote.org/emoji/blobcat', now(), now()),
          (5, 'blobcat', 'Remote.org', 'https://remote.org/emoji/blobcat', now(), now()),
          (6, 'Blobcat', 'remote.org', 'https://remote.org/emoji/Blobcat', now(), now());

        -- favourites

        INSERT INTO "favourites"
          (account_id, status_id, created_at, updated_at)
        VALUES
          (1, 1, now(), now()),
          (1, 7, now(), now()),
          (4, 1, now(), now()),
          (3, 1, now(), now()),
          (5, 1, now(), now());

        -- pinned statuses

        INSERT INTO "status_pins"
          (account_id, status_id, created_at, updated_at)
        VALUES
          (1, 1, now(), now()),
          (3, 6, now(), now()),
          (4, 7, now(), now());

        -- follows

        INSERT INTO "follows"
          (id, account_id, target_account_id, created_at, updated_at)
        VALUES
          (1, 1, 5, now(), now()),
          (2, 6, 2, now(), now()),
          (3, 5, 2, now(), now()),
          (4, 6, 1, now(), now());

        -- follow requests

        INSERT INTO "follow_requests"
          (account_id, target_account_id, created_at, updated_at)
        VALUES
          (2, 5, now(), now()),
          (5, 1, now(), now());

        -- notifications

        INSERT INTO "notifications"
          (id, from_account_id, account_id, activity_type, activity_id, created_at, updated_at)
        VALUES
          (1, 6, 2, 'Follow', 2, now(), now()),
          (2, 2, 1, 'Mention', 4, now(), now()),
          (3, 1, 2, 'Mention', 5, now(), now());
      SQL
    end
  end
end
