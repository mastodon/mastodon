# frozen_string_literal: true

class AddUniqueIndexOnAccountsUri < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Dummy classes to make migration possible across version changes
  class Account < ApplicationRecord; end
  class AccountDeletionRequest < ApplicationRecord; end
  class AccountModerationNote < ApplicationRecord; end
  class AccountNote < ApplicationRecord; end
  class AccountPin < ApplicationRecord; end
  class AccountStat < ApplicationRecord; end
  class Appeal < ApplicationRecord; end
  class Block < ApplicationRecord; end
  class CanonicalEmailBlock < ApplicationRecord; end
  class Collection < ApplicationRecord; end
  class CollectionItem < ApplicationRecord; end
  class Favourite < ApplicationRecord; end
  class Follow < ApplicationRecord; end
  class FollowRecommendationSuppression < ApplicationRecord; end
  class FollowRequest < ApplicationRecord; end
  class ListAccount < ApplicationRecord; end
  class MediaAttachment < ApplicationRecord; end
  class Mention < ApplicationRecord; end
  class Mute < ApplicationRecord; end
  class Notification < ApplicationRecord; end
  class NotificationPermission < ApplicationRecord; end
  class NotificationRequest < ApplicationRecord; end
  class Poll < ApplicationRecord; end
  class PollVote < ApplicationRecord; end
  class Quote < ApplicationRecord; end
  class Report < ApplicationRecord; end
  class SeveredRelationship < ApplicationRecord; end
  class Status < ApplicationRecord; end
  class StatusPin < ApplicationRecord; end
  class TagFollow < ApplicationRecord; end
  class Tombstone < ApplicationRecord; end

  def up
    add_index :accounts, :uri, algorithm: :concurrently, unique: true
  rescue ActiveRecord::RecordNotUnique
    deduplicate_and_reindex!
  rescue
    remove_index :accounts, name: :index_accounts_on_uri
    raise
  end

  def down
    remove_index :accounts, name: :index_accounts_on_uri
  end

  private

  def deduplicate_and_reindex!
    deduplicate_accounts!

    safety_assured { execute 'REINDEX INDEX CONCURRENTLY index_accounts_on_uri' }
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def deduplicate_accounts!
    duplicate_uris = select_all('SELECT uri FROM accounts WHERE uri IS NOT NULL GROUP BY uri HAVING count(*) > 1').rows

    duplicate_uris.each do |uri|
      # Fetch the conflicting accounts and keep the most recently-discovered one as reference
      duplicate_records = Account.where(uri: uri).reorder(Arel.sql("COALESCE(last_webfingered_at, 'epoch'::date)"), :created_at, :id).to_a
      reference_account = duplicate_records.pop

      duplicate_records.each do |other_account|
        merge_accounts!(reference_account, other_account)
        other_account.destroy
      end
    end
  end

  def merge_accounts!(account, other_account)
    {
      account_id: [
        Status, StatusPin, MediaAttachment, Poll, Report, Tombstone, Favourite,
        Follow, FollowRequest, Block, Mute,
        AccountModerationNote, AccountPin, AccountStat, ListAccount,
        PollVote, Mention, AccountDeletionRequest, AccountNote, FollowRecommendationSuppression,
        Appeal, TagFollow, Quote, Collection, CollectionItem
      ],
      from_account_id: [
        Notification, NotificationPermission, NotificationRequest
      ],
      target_account_id: [
        Follow, FollowRequest, Block, Mute, AccountModerationNote, AccountPin, AccountNote
      ],
      reference_account_id: [CanonicalEmailBlock],
      account_warning_id: [Appeal],
      local_account_id: [SeveredRelationship],
      remote_account_id: [SeveredRelationship],
      quoted_account_id: [Quote],
    }.each do |attribute, classes|
      classes.each do |klass|
        klass.where({ attribute => other_account.id }).reorder(nil).find_each do |record|
          record.update_attribute(attribute, account.id)
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end
    end
  end
end
