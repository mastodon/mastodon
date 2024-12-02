# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Maintenance < Base
    MIN_SUPPORTED_VERSION = 2019_10_01_213028
    MAX_SUPPORTED_VERSION = 2023_10_23_105620

    # Stubs to enjoy ActiveRecord queries while not depending on a particular
    # version of the code/database

    class Status < ApplicationRecord; end
    class StatusPin < ApplicationRecord; end
    class Poll < ApplicationRecord; end
    class Report < ApplicationRecord; end
    class Tombstone < ApplicationRecord; end
    class Favourite < ApplicationRecord; end
    class Follow < ApplicationRecord; end
    class FollowRequest < ApplicationRecord; end
    class Block < ApplicationRecord; end
    class Mute < ApplicationRecord; end
    class AccountIdentityProof < ApplicationRecord; end
    class AccountModerationNote < ApplicationRecord; end
    class AccountPin < ApplicationRecord; end
    class ListAccount < ApplicationRecord; end
    class PollVote < ApplicationRecord; end
    class Mention < ApplicationRecord; end
    class Notification < ApplicationRecord; end
    class NotificationPermission < ApplicationRecord; end
    class NotificationRequest < ApplicationRecord; end
    class AccountDomainBlock < ApplicationRecord; end
    class AnnouncementReaction < ApplicationRecord; end
    class FeaturedTag < ApplicationRecord; end
    class CustomEmoji < ApplicationRecord; end
    class CustomEmojiCategory < ApplicationRecord; end
    class Bookmark < ApplicationRecord; end
    class WebauthnCredential < ApplicationRecord; end
    class FollowRecommendationSuppression < ApplicationRecord; end
    class CanonicalEmailBlock < ApplicationRecord; end
    class Appeal < ApplicationRecord; end
    class Webhook < ApplicationRecord; end
    class BulkImport < ApplicationRecord; end
    class SoftwareUpdate < ApplicationRecord; end
    class SeveredRelationship < ApplicationRecord; end
    class TagFollow < ApplicationRecord; end

    class DomainBlock < ApplicationRecord
      enum :severity, { silence: 0, suspend: 1, noop: 2 }
      scope :by_severity, -> { in_order_of(:severity, %w(noop silence suspend)).order(:domain) }
    end

    class PreviewCard < ApplicationRecord
      self.inheritance_column = false
    end

    class MediaAttachment < ApplicationRecord
      self.inheritance_column = nil
    end

    class AccountStat < ApplicationRecord
      belongs_to :account, inverse_of: :account_stat
    end

    # Dummy class, to make migration possible across version changes
    class Account < ApplicationRecord
      has_one :user, inverse_of: :account
      has_one :account_stat, inverse_of: :account

      scope :local, -> { where(domain: nil) }

      def local?
        domain.nil?
      end

      def acct
        local? ? username : "#{username}@#{domain}"
      end

      def db_table_exists?(table)
        ActiveRecord::Base.connection.table_exists?(table)
      end

      # This is a duplicate of the Account::Merging concern because we need it
      # to be independent from code version.
      def merge_with!(other_account)
        # Since it's the same remote resource, the remote resource likely
        # already believes we are following/blocking, so it's safe to
        # re-attribute the relationships too. However, during the presence
        # of the index bug users could have *also* followed the reference
        # account already, therefore mass update will not work and we need
        # to check for (and skip past) uniqueness errors

        owned_classes = [
          Status, StatusPin, MediaAttachment, Poll, Report, Tombstone, Favourite,
          Follow, FollowRequest, Block, Mute,
          AccountModerationNote, AccountPin, AccountStat, ListAccount,
          PollVote, Mention
        ]
        owned_classes << AccountDeletionRequest if db_table_exists?(:account_deletion_requests)
        owned_classes << AccountNote if db_table_exists?(:account_notes)
        owned_classes << FollowRecommendationSuppression if db_table_exists?(:follow_recommendation_suppressions)
        owned_classes << AccountIdentityProof if db_table_exists?(:account_identity_proofs)
        owned_classes << Appeal if db_table_exists?(:appeals)
        owned_classes << BulkImport if db_table_exists?(:bulk_imports)
        owned_classes << TagFollow if db_table_exists?(:tag_follows)

        owned_classes.each do |klass|
          klass.where(account_id: other_account.id).find_each do |record|
            record.update_attribute(:account_id, id)
          rescue ActiveRecord::RecordNotUnique
            next
          end
        end

        from_classes = [Notification]
        from_classes << NotificationPermission if db_table_exists?(:notification_permissions)
        from_classes << NotificationRequest if db_table_exists?(:notification_requests)

        from_classes.each do |klass|
          klass.where(from_account_id: other_account.id).find_each do |record|
            record.update_attribute(:from_account_id, id)
          rescue ActiveRecord::RecordNotUnique
            next
          end
        end

        target_classes = [Follow, FollowRequest, Block, Mute, AccountModerationNote, AccountPin]
        target_classes << AccountNote if db_table_exists?(:account_notes)

        target_classes.each do |klass|
          klass.where(target_account_id: other_account.id).find_each do |record|
            record.update_attribute(:target_account_id, id)
          rescue ActiveRecord::RecordNotUnique
            next
          end
        end

        if db_table_exists?(:canonical_email_blocks)
          CanonicalEmailBlock.where(reference_account_id: other_account.id).find_each do |record|
            record.update_attribute(:reference_account_id, id)
          end
        end

        if db_table_exists?(:appeals)
          Appeal.where(account_warning_id: other_account.id).find_each do |record|
            record.update_attribute(:account_warning_id, id)
          end
        end

        if db_table_exists?(:severed_relationships)
          SeveredRelationship.where(local_account_id: other_account.id).reorder(nil).find_each do |record|
            record.update_attribute(:local_account_id, id)
          rescue ActiveRecord::RecordNotUnique
            next
          end

          SeveredRelationship.where(remote_account_id: other_account.id).reorder(nil).find_each do |record|
            record.update_attribute(:remote_account_id, id)
          rescue ActiveRecord::RecordNotUnique
            next
          end
        end
      end
    end

    class User < ApplicationRecord
      belongs_to :account, inverse_of: :user
    end

    desc 'fix-duplicates', 'Fix duplicates in database and rebuild indexes'
    long_desc <<~LONG_DESC
      Delete or merge duplicate accounts, statuses, emojis, etc. and rebuild indexes.

      This is useful if your database indexes are corrupted because of issues such as https://wiki.postgresql.org/wiki/Locale_data_changes

      Mastodon has to be stopped to run this task, which will take a long time and may be destructive.
    LONG_DESC
    def fix_duplicates
      verify_system_ready!

      process_deduplications

      deduplication_cleanup_tasks

      say 'Finished!'
    end

    private

    def verify_system_ready!
      verify_schema_version!
      verify_sidekiq_not_active!
      verify_backup_warning!
    end

    def process_deduplications
      deduplicate_users!
      deduplicate_account_domain_blocks!
      deduplicate_account_identity_proofs!
      deduplicate_announcement_reactions!
      deduplicate_conversations!
      deduplicate_custom_emojis!
      deduplicate_custom_emoji_categories!
      deduplicate_domain_allows!
      deduplicate_domain_blocks!
      deduplicate_unavailable_domains!
      deduplicate_email_domain_blocks!
      deduplicate_media_attachments!
      deduplicate_preview_cards!
      deduplicate_statuses!
      deduplicate_accounts!
      deduplicate_tags!
      deduplicate_webauthn_credentials!
      deduplicate_webhooks!
      deduplicate_software_updates!
    end

    def deduplication_cleanup_tasks
      refresh_instances_view if schema_has_instances_view?
      Rails.cache.clear
    end

    def refresh_instances_view
      Scenic.database.refresh_materialized_view('instances', concurrently: true, cascade: false)
    end

    def schema_has_instances_view?
      migrator_version >= 2020_12_06_004238
    end

    def verify_schema_version!
      if migrator_version < MIN_SUPPORTED_VERSION
        fail_with_message <<~ERROR
          Your version of the database schema is too old and is not supported by this script.
          Please update to at least Mastodon 3.0.0 before running this script.
        ERROR
      elsif migrator_version > MAX_SUPPORTED_VERSION
        say 'Your version of the database schema is more recent than this script, this may cause unexpected errors.', :yellow
        fail_with_message 'Stopping maintenance script because data is more recent than script version.' unless yes?('Continue anyway? (Yes/No)')
      end
    end

    def verify_sidekiq_not_active!
      fail_with_message 'It seems Sidekiq is running. All Mastodon processes need to be stopped when using this script.' if Sidekiq::ProcessSet.new.any?
    end

    def verify_backup_warning!
      say 'This task will take a long time to run and is potentially destructive.', :yellow
      say 'Please make sure to stop Mastodon and have a backup.', :yellow
      fail_with_message 'Maintenance process stopped.' unless yes?('Continue? (Yes/No)')
    end

    def deduplicate_accounts!
      remove_index_if_exists!(:accounts, 'index_accounts_on_username_and_domain_lower')

      say 'Deduplicating accounts… for local accounts, you will be asked to chose which account to keep unchanged.'

      duplicate_record_ids(:accounts, "lower(username), COALESCE(lower(domain), '')").each do |row|
        accounts = Account.where(id: row['ids'].split(','))

        if accounts.first.local?
          deduplicate_local_accounts!(accounts)
        else
          deduplicate_remote_accounts!(accounts)
        end
      end

      say 'Restoring index_accounts_on_username_and_domain_lower…'
      if migrator_version < 2020_06_20_164023
        database_connection.add_index :accounts, 'lower (username), lower(domain)', name: 'index_accounts_on_username_and_domain_lower', unique: true
      else
        database_connection.add_index :accounts, "lower (username), COALESCE(lower(domain), '')", name: 'index_accounts_on_username_and_domain_lower', unique: true
      end

      say 'Reindexing textual indexes on accounts…'
      rebuild_index(:search_index)
      rebuild_index(:index_accounts_on_uri)
      rebuild_index(:index_accounts_on_url)
      rebuild_index(:index_accounts_on_domain_and_id) if migrator_version >= 2023_05_24_190515
    end

    def deduplicate_users!
      remove_index_if_exists!(:users, 'index_users_on_confirmation_token')
      remove_index_if_exists!(:users, 'index_users_on_email')
      remove_index_if_exists!(:users, 'index_users_on_remember_token')
      remove_index_if_exists!(:users, 'index_users_on_reset_password_token')

      say 'Deduplicating user records…'

      deduplicate_users_process_email
      deduplicate_users_process_confirmation_token
      deduplicate_users_process_remember_token
      deduplicate_users_process_password_token

      say 'Restoring users indexes…'
      database_connection.add_index :users, ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true
      database_connection.add_index :users, ['email'], name: 'index_users_on_email', unique: true
      database_connection.add_index :users, ['remember_token'], name: 'index_users_on_remember_token', unique: true if migrator_version < 2022_01_18_183010

      if migrator_version < 2022_03_10_060641
        database_connection.add_index :users, ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
      else
        database_connection.add_index :users, ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true, where: 'reset_password_token IS NOT NULL', opclass: :text_pattern_ops
      end

      rebuild_index(:index_users_on_unconfirmed_email) if migrator_version >= 2023_07_02_151753
    end

    def deduplicate_users_process_email
      duplicate_record_ids(:users, 'email').each do |row|
        users = User.where(id: row['ids'].split(',')).order(updated_at: :desc).includes(:account).to_a
        ref_user = users.shift
        say "Multiple users registered with e-mail address #{ref_user.email}.", :yellow
        say "e-mail will be disabled for the following accounts: #{users.map { |user| user.account.acct }.join(', ')}", :yellow
        say 'Please reach out to them and set another address with `tootctl account modify` or delete them.', :yellow

        users.each_with_index do |user, index|
          user.update!(email: "#{index} " + user.email)
        end
      end
    end

    def deduplicate_users_process_confirmation_token
      duplicate_record_ids_without_nulls(:users, 'confirmation_token').each do |row|
        users = User.where(id: row['ids'].split(',')).order(created_at: :desc).includes(:account).to_a.drop(1)
        say "Unsetting confirmation token for those accounts: #{users.map { |user| user.account.acct }.join(', ')}", :yellow

        users.each do |user|
          user.update!(confirmation_token: nil)
        end
      end
    end

    def deduplicate_users_process_remember_token
      if migrator_version < 2022_01_18_183010
        duplicate_record_ids_without_nulls(:users, 'remember_token').each do |row|
          users = User.where(id: row['ids'].split(',')).order(updated_at: :desc).to_a.drop(1)
          say "Unsetting remember token for those accounts: #{users.map { |user| user.account.acct }.join(', ')}", :yellow

          users.each do |user|
            user.update!(remember_token: nil)
          end
        end
      end
    end

    def deduplicate_users_process_password_token
      duplicate_record_ids_without_nulls(:users, 'reset_password_token').each do |row|
        users = User.where(id: row['ids'].split(',')).order(updated_at: :desc).includes(:account).to_a.drop(1)
        say "Unsetting password reset token for those accounts: #{users.map { |user| user.account.acct }.join(', ')}", :yellow

        users.each do |user|
          user.update!(reset_password_token: nil)
        end
      end
    end

    def deduplicate_account_domain_blocks!
      remove_index_if_exists!(:account_domain_blocks, 'index_account_domain_blocks_on_account_id_and_domain')

      say 'Removing duplicate account domain blocks…'
      duplicate_record_ids(:account_domain_blocks, 'account_id, domain').each do |row|
        AccountDomainBlock.where(id: row['ids'].split(',').drop(1)).delete_all
      end

      say 'Restoring account domain blocks indexes…'
      database_connection.add_index :account_domain_blocks, %w(account_id domain), name: 'index_account_domain_blocks_on_account_id_and_domain', unique: true
    end

    def deduplicate_account_identity_proofs!
      return unless db_table_exists?(:account_identity_proofs)

      remove_index_if_exists!(:account_identity_proofs, 'index_account_proofs_on_account_and_provider_and_username')

      say 'Removing duplicate account identity proofs…'
      duplicate_record_ids(:account_identity_proofs, 'account_id, provider, provider_username').each do |row|
        AccountIdentityProof.where(id: row['ids'].split(',')).order(id: :desc).to_a.drop(1).each(&:destroy)
      end

      say 'Restoring account identity proofs indexes…'
      database_connection.add_index :account_identity_proofs, %w(account_id provider provider_username), name: 'index_account_proofs_on_account_and_provider_and_username', unique: true
    end

    def deduplicate_announcement_reactions!
      return unless db_table_exists?(:announcement_reactions)

      remove_index_if_exists!(:announcement_reactions, 'index_announcement_reactions_on_account_id_and_announcement_id')

      say 'Removing duplicate announcement reactions…'
      duplicate_record_ids(:announcement_reactions, 'account_id, announcement_id, name').each do |row|
        AnnouncementReaction.where(id: row['ids'].split(',')).order(id: :desc).to_a.drop(1).each(&:destroy)
      end

      say 'Restoring announcement_reactions indexes…'
      database_connection.add_index :announcement_reactions, %w(account_id announcement_id name), name: 'index_announcement_reactions_on_account_id_and_announcement_id', unique: true
    end

    def deduplicate_conversations!
      remove_index_if_exists!(:conversations, 'index_conversations_on_uri')

      say 'Deduplicating conversations…'
      duplicate_record_ids_without_nulls(:conversations, 'uri').each do |row|
        conversations = Conversation.where(id: row['ids'].split(',')).order(id: :desc).to_a

        ref_conversation = conversations.shift

        conversations.each do |other|
          merge_conversations!(ref_conversation, other)
          other.destroy
        end
      end

      say 'Restoring conversations indexes…'
      if migrator_version < 2022_03_07_083603
        database_connection.add_index :conversations, ['uri'], name: 'index_conversations_on_uri', unique: true
      else
        database_connection.add_index :conversations, ['uri'], name: 'index_conversations_on_uri', unique: true, where: 'uri IS NOT NULL', opclass: :text_pattern_ops
      end
    end

    def deduplicate_custom_emojis!
      remove_index_if_exists!(:custom_emojis, 'index_custom_emojis_on_shortcode_and_domain')

      say 'Deduplicating custom_emojis…'
      duplicate_record_ids(:custom_emojis, 'shortcode, domain').each do |row|
        emojis = CustomEmoji.where(id: row['ids'].split(',')).order(id: :desc).to_a

        ref_emoji = emojis.shift

        emojis.each do |other|
          merge_custom_emojis!(ref_emoji, other)
          other.destroy
        end
      end

      say 'Restoring custom_emojis indexes…'
      database_connection.add_index :custom_emojis, %w(shortcode domain), name: 'index_custom_emojis_on_shortcode_and_domain', unique: true
    end

    def deduplicate_custom_emoji_categories!
      remove_index_if_exists!(:custom_emoji_categories, 'index_custom_emoji_categories_on_name')

      say 'Deduplicating custom_emoji_categories…'
      duplicate_record_ids(:custom_emoji_categories, 'name').each do |row|
        categories = CustomEmojiCategory.where(id: row['ids'].split(',')).order(id: :desc).to_a

        ref_category = categories.shift

        categories.each do |other|
          merge_custom_emoji_categories!(ref_category, other)
          other.destroy
        end
      end

      say 'Restoring custom_emoji_categories indexes…'
      database_connection.add_index :custom_emoji_categories, ['name'], name: 'index_custom_emoji_categories_on_name', unique: true
    end

    def deduplicate_domain_allows!
      remove_index_if_exists!(:domain_allows, 'index_domain_allows_on_domain')

      say 'Deduplicating domain_allows…'
      duplicate_record_ids(:domain_allows, 'domain').each do |row|
        DomainAllow.where(id: row['ids'].split(',')).order(id: :desc).to_a.drop(1).each(&:destroy)
      end

      say 'Restoring domain_allows indexes…'
      database_connection.add_index :domain_allows, ['domain'], name: 'index_domain_allows_on_domain', unique: true
    end

    def deduplicate_domain_blocks!
      remove_index_if_exists!(:domain_blocks, 'index_domain_blocks_on_domain')

      say 'Deduplicating domain_blocks…'
      duplicate_record_ids(:domain_blocks, 'domain').each do |row|
        domain_blocks = DomainBlock.where(id: row['ids'].split(',')).by_severity.reverse.to_a

        reject_media = domain_blocks.any?(&:reject_media?)
        reject_reports = domain_blocks.any?(&:reject_reports?)

        reference_block = domain_blocks.shift

        private_comment = domain_blocks.reduce(reference_block.private_comment.presence) { |a, b| a || b.private_comment.presence }
        public_comment  = domain_blocks.reduce(reference_block.public_comment.presence)  { |a, b| a || b.public_comment.presence }

        reference_block.update!(reject_media: reject_media, reject_reports: reject_reports, private_comment: private_comment, public_comment: public_comment)

        domain_blocks.each(&:destroy)
      end

      say 'Restoring domain_blocks indexes…'
      database_connection.add_index :domain_blocks, ['domain'], name: 'index_domain_blocks_on_domain', unique: true
    end

    def deduplicate_unavailable_domains!
      return unless db_table_exists?(:unavailable_domains)

      remove_index_if_exists!(:unavailable_domains, 'index_unavailable_domains_on_domain')

      say 'Deduplicating unavailable_domains…'
      duplicate_record_ids(:unavailable_domains, 'domain').each do |row|
        UnavailableDomain.where(id: row['ids'].split(',')).order(id: :desc).to_a.drop(1).each(&:destroy)
      end

      say 'Restoring unavailable_domains indexes…'
      database_connection.add_index :unavailable_domains, ['domain'], name: 'index_unavailable_domains_on_domain', unique: true
    end

    def deduplicate_email_domain_blocks!
      remove_index_if_exists!(:email_domain_blocks, 'index_email_domain_blocks_on_domain')

      say 'Deduplicating email_domain_blocks…'
      duplicate_record_ids(:email_domain_blocks, 'domain').each do |row|
        domain_blocks = EmailDomainBlock.where(id: row['ids'].split(',')).order(EmailDomainBlock.arel_table[:parent_id].asc.nulls_first).to_a
        domain_blocks.drop(1).each(&:destroy)
      end

      say 'Restoring email_domain_blocks indexes…'
      database_connection.add_index :email_domain_blocks, ['domain'], name: 'index_email_domain_blocks_on_domain', unique: true
    end

    def deduplicate_media_attachments!
      remove_index_if_exists!(:media_attachments, 'index_media_attachments_on_shortcode')

      say 'Deduplicating media_attachments…'
      duplicate_record_ids_without_nulls(:media_attachments, 'shortcode').each do |row|
        MediaAttachment.where(id: row['ids'].split(',').drop(1)).update_all(shortcode: nil)
      end

      say 'Restoring media_attachments indexes…'
      if migrator_version < 2022_03_10_060626
        database_connection.add_index :media_attachments, ['shortcode'], name: 'index_media_attachments_on_shortcode', unique: true
      else
        database_connection.add_index :media_attachments, ['shortcode'], name: 'index_media_attachments_on_shortcode', unique: true, where: 'shortcode IS NOT NULL', opclass: :text_pattern_ops
      end
    end

    def deduplicate_preview_cards!
      remove_index_if_exists!(:preview_cards, 'index_preview_cards_on_url')

      say 'Deduplicating preview_cards…'
      duplicate_record_ids(:preview_cards, 'url').each do |row|
        PreviewCard.where(id: row['ids'].split(',')).order(id: :desc).to_a.drop(1).each(&:destroy)
      end

      say 'Restoring preview_cards indexes…'
      database_connection.add_index :preview_cards, ['url'], name: 'index_preview_cards_on_url', unique: true
    end

    def deduplicate_statuses!
      remove_index_if_exists!(:statuses, 'index_statuses_on_uri')

      say 'Deduplicating statuses…'
      duplicate_record_ids_without_nulls(:statuses, 'uri').each do |row|
        statuses = Status.where(id: row['ids'].split(',')).order(id: :asc).to_a
        ref_status = statuses.shift
        statuses.each do |status|
          merge_statuses!(ref_status, status) if status.account_id == ref_status.account_id
          status.destroy
        end
      end

      say 'Restoring statuses indexes…'
      if migrator_version < 2022_03_10_060706
        database_connection.add_index :statuses, ['uri'], name: 'index_statuses_on_uri', unique: true
      else
        database_connection.add_index :statuses, ['uri'], name: 'index_statuses_on_uri', unique: true, where: 'uri IS NOT NULL', opclass: :text_pattern_ops
      end
    end

    def deduplicate_tags!
      remove_index_if_exists!(:tags, 'index_tags_on_name_lower')
      remove_index_if_exists!(:tags, 'index_tags_on_name_lower_btree')

      say 'Deduplicating tags…'
      duplicate_record_ids(:tags, 'lower((name)::text)').each do |row|
        tags = Tag.where(id: row['ids'].split(',')).order(Arel.sql('(usable::int + trendable::int + listable::int) desc')).to_a
        ref_tag = tags.shift
        tags.each do |tag|
          merge_tags!(ref_tag, tag)
          tag.destroy
        end
      end

      say 'Restoring tags indexes…'
      if migrator_version < 2021_04_21_121431
        database_connection.add_index :tags, 'lower((name)::text)', name: 'index_tags_on_name_lower', unique: true
      else
        database_connection.execute 'CREATE UNIQUE INDEX index_tags_on_name_lower_btree ON tags (lower(name) text_pattern_ops)'
      end
    end

    def deduplicate_webauthn_credentials!
      return unless db_table_exists?(:webauthn_credentials)

      remove_index_if_exists!(:webauthn_credentials, 'index_webauthn_credentials_on_external_id')

      say 'Deduplicating webauthn_credentials…'
      duplicate_record_ids(:webauthn_credentials, 'external_id').each do |row|
        WebauthnCredential.where(id: row['ids'].split(',')).order(id: :desc).to_a.drop(1).each(&:destroy)
      end

      say 'Restoring webauthn_credentials indexes…'
      database_connection.add_index :webauthn_credentials, ['external_id'], name: 'index_webauthn_credentials_on_external_id', unique: true
    end

    def deduplicate_webhooks!
      return unless db_table_exists?(:webhooks)

      remove_index_if_exists!(:webhooks, 'index_webhooks_on_url')

      say 'Deduplicating webhooks…'
      duplicate_record_ids(:webhooks, 'url').each do |row|
        Webhook.where(id: row['ids'].split(',')).order(id: :desc).drop(1).each(&:destroy)
      end

      say 'Restoring webhooks indexes…'
      database_connection.add_index :webhooks, ['url'], name: 'index_webhooks_on_url', unique: true
    end

    def deduplicate_software_updates!
      # Not bothering with this, it's data that will be recovered with the scheduler
      SoftwareUpdate.delete_all
    end

    def deduplicate_local_accounts!(scope)
      accounts = scope.order(id: :desc).includes(:account_stat, :user).to_a

      say "Multiple local accounts were found for username '#{accounts.first.username}'.", :yellow
      say 'All those accounts are distinct accounts but only the most recently-created one is fully-functional.', :yellow

      accounts.each_with_index do |account, idx|
        say format(
          '%<index>2d. %<username>s: created at: %<created_at>s; updated at: %<updated_at>s; last logged in at: %<last_log_in_at>s; statuses: %<status_count>5d; last status at: %<last_status_at>s',
          index: idx,
          username: account.username,
          created_at: account.created_at,
          updated_at: account.updated_at,
          last_log_in_at: account.user&.last_sign_in_at&.to_s || 'N/A',
          status_count: account.account_stat&.statuses_count || 0,
          last_status_at: account.account_stat&.last_status_at || 'N/A'
        )
      end

      say 'Please chose the one to keep unchanged, other ones will be automatically renamed.'

      ref_id = ask('Account to keep unchanged:', required: true, default: 0).to_i

      accounts.delete_at(ref_id)

      i = 0
      accounts.each do |account|
        i += 1
        username = account.username + "_#{i}"

        while Account.local.exists?(username: username)
          i += 1
          username = account.username + "_#{i}"
        end

        account.update!(username: username)
      end
    end

    def deduplicate_remote_accounts!(scope)
      accounts = scope.order(updated_at: :desc).to_a

      reference_account = accounts.shift

      accounts.each do |other_account|
        if other_account.public_key == reference_account.public_key
          # The accounts definitely point to the same resource, so
          # it's safe to re-attribute content and relationships
          reference_account.merge_with!(other_account)
        end

        other_account.destroy
      end
    end

    def merge_conversations!(main_conv, duplicate_conv)
      owned_classes = [ConversationMute, AccountConversation]
      owned_classes.each do |klass|
        klass.where(conversation_id: duplicate_conv.id).find_each do |record|
          record.update_attribute(:account_id, main_conv.id)
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end
    end

    def merge_custom_emojis!(main_emoji, duplicate_emoji)
      owned_classes = [AnnouncementReaction]
      owned_classes.each do |klass|
        klass.where(custom_emoji_id: duplicate_emoji.id).update_all(custom_emoji_id: main_emoji.id)
      end
    end

    def merge_custom_emoji_categories!(main_category, duplicate_category)
      owned_classes = [CustomEmoji]
      owned_classes.each do |klass|
        klass.where(category_id: duplicate_category.id).update_all(category_id: main_category.id)
      end
    end

    def merge_statuses!(main_status, duplicate_status)
      owned_classes = [Favourite, Mention, Poll]
      owned_classes << Bookmark if db_table_exists?(:bookmarks)
      owned_classes.each do |klass|
        klass.where(status_id: duplicate_status.id).find_each do |record|
          record.update_attribute(:status_id, main_status.id)
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end

      StatusPin.where(account_id: main_status.account_id, status_id: duplicate_status.id).find_each do |record|
        record.update_attribute(:status_id, main_status.id)
      rescue ActiveRecord::RecordNotUnique
        next
      end

      Status.where(in_reply_to_id: duplicate_status.id).find_each do |record|
        record.update_attribute(:in_reply_to_id, main_status.id)
      rescue ActiveRecord::RecordNotUnique
        next
      end

      Status.where(reblog_of_id: duplicate_status.id).find_each do |record|
        record.update_attribute(:reblog_of_id, main_status.id)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end

    def merge_tags!(main_tag, duplicate_tag)
      [FeaturedTag].each do |klass|
        klass.where(tag_id: duplicate_tag.id).find_each do |record|
          record.update_attribute(:tag_id, main_tag.id)
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end
    end

    def migrator_version
      ActiveRecord::Migrator.current_version
    end

    def duplicate_record_ids_without_nulls(table, group_by)
      database_connection.select_all(<<~SQL.squish)
        SELECT string_agg(id::text, ',') AS ids
        FROM #{table}
        WHERE #{group_by} IS NOT NULL
        GROUP BY #{group_by}
        HAVING COUNT(*) > 1
      SQL
    end

    def duplicate_record_ids(table, group_by)
      database_connection.select_all(<<~SQL.squish)
        SELECT string_agg(id::text, ',') AS ids
        FROM #{table}
        GROUP BY #{group_by}
        HAVING COUNT(*) > 1
      SQL
    end

    def remove_index_if_exists!(table, name)
      database_connection.remove_index(table, name: name) if database_connection.index_name_exists?(table, name)
    rescue ArgumentError, ActiveRecord::StatementInvalid
      nil
    end

    def database_connection
      ActiveRecord::Base.connection
    end

    def db_table_exists?(table)
      database_connection.table_exists?(table)
    end

    def rebuild_index(name)
      database_connection.execute("REINDEX INDEX #{name}")
    end
  end
end
