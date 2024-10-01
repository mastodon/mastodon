# frozen_string_literal: true

require_relative '../../lib/mastodon/migration_warning'

class FixAccountsUniqueIndex < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationWarning

  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    has_one :user, inverse_of: :account

    def local?
      domain.nil?
    end

    def acct
      local? ? username : "#{username}@#{domain}"
    end
  end

  class StreamEntry < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account, inverse_of: :stream_entries
  end

  class Status < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account
  end

  class Mention < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account
  end

  class StatusPin < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account
  end

  disable_ddl_transaction!

  def up
    migration_duration_warning(<<~EXPLANATION)
      This migration will irreversibly delete user accounts with duplicate
      usernames. You may use the `rake mastodon:maintenance:find_duplicate_usernames`
      task to manually deal with such accounts before running this migration.
    EXPLANATION

    duplicates = Account.connection.select_all('SELECT string_agg(id::text, \',\') AS ids FROM accounts GROUP BY lower(username), lower(domain) HAVING count(*) > 1').to_ary

    duplicates.each do |row|
      deduplicate_account!(row['ids'].split(','))
    end

    remove_index :accounts, name: 'index_accounts_on_username_and_domain_lower' if index_name_exists?(:accounts, 'index_accounts_on_username_and_domain_lower')
    safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_accounts_on_username_and_domain_lower ON accounts (lower(username), lower(domain))' }
    remove_index :accounts, name: 'index_accounts_on_username_and_domain' if index_name_exists?(:accounts, 'index_accounts_on_username_and_domain')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def deduplicate_account!(account_ids)
    accounts          = Account.where(id: account_ids).to_a
    accounts          = accounts.first.local? ? accounts.sort_by(&:created_at) : accounts.sort_by(&:updated_at).reverse
    reference_account = accounts.shift

    say_with_time "Deduplicating @#{reference_account.acct} (#{accounts.size} duplicates)..." do
      accounts.each do |other_account|
        if other_account.public_key == reference_account.public_key
          # The accounts definitely point to the same resource, so
          # it's safe to re-attribute content and relationships
          merge_accounts!(reference_account, other_account)
        elsif other_account.local?
          # Since domain is in the GROUP BY clause, both accounts
          # are always either going to be local or not local, so only
          # one check is needed. Since we cannot support two users with
          # the same username locally, one has to go. 😢
          other_account.user&.destroy
        end

        other_account.destroy
      end
    end
  end

  def merge_accounts!(main_account, duplicate_account)
    [Status, Mention, StatusPin, StreamEntry].each do |klass|
      klass.where(account_id: duplicate_account.id).in_batches.update_all(account_id: main_account.id)
    end

    # Since it's the same remote resource, the remote resource likely
    # already believes we are following/blocking, so it's safe to
    # re-attribute the relationships too. However, during the presence
    # of the index bug users could have *also* followed the reference
    # account already, therefore mass update will not work and we need
    # to check for (and skip past) uniqueness errors
    [Favourite, Follow, FollowRequest, Block, Mute].each do |klass|
      klass.where(account_id: duplicate_account.id).find_each do |record|
        record.update_attribute(:account_id, main_account.id)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end

    [Follow, FollowRequest, Block, Mute].each do |klass|
      klass.where(target_account_id: duplicate_account.id).find_each do |record|
        record.update_attribute(:target_account_id, main_account.id)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end
end
