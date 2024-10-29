# frozen_string_literal: true

module Account::Associations
  extend ActiveSupport::Concern

  included do
    # Core associations
    with_options dependent: :destroy do
      has_many :account_moderation_notes, inverse_of: :account
      has_many :account_pins, inverse_of: :account
      has_many :account_warnings, inverse_of: :account
      has_many :aliases, class_name: 'AccountAlias', inverse_of: :account
      has_many :bookmarks, inverse_of: :account
      has_many :conversations, class_name: 'AccountConversation', inverse_of: :account
      has_many :custom_filters, inverse_of: :account
      has_many :favourites, inverse_of: :account
      has_many :featured_tags, -> { includes(:tag) }, inverse_of: :account
      has_many :list_accounts, inverse_of: :account
      has_many :media_attachments
      has_many :mentions, inverse_of: :account
      has_many :migrations, class_name: 'AccountMigration', inverse_of: :account
      has_many :notification_permissions, inverse_of: :account
      has_many :notification_requests, inverse_of: :account
      has_many :notifications, inverse_of: :account
      has_many :owned_lists, class_name: 'List', inverse_of: :account
      has_many :polls
      has_many :report_notes
      has_many :reports, inverse_of: :account
      has_many :scheduled_statuses, inverse_of: :account
      has_many :status_pins, inverse_of: :account
      has_many :statuses, inverse_of: :account
      has_many :strikes, class_name: 'AccountWarning', foreign_key: :target_account_id, inverse_of: :target_account
      has_many :targeted_moderation_notes, class_name: 'AccountModerationNote', foreign_key: :target_account_id, inverse_of: :target_account
      has_many :targeted_reports, class_name: 'Report', foreign_key: :target_account_id, inverse_of: :target_account
      has_one :deletion_request, class_name: 'AccountDeletionRequest', inverse_of: :account
      has_one :notification_policy, inverse_of: :account
      has_one :user, inverse_of: :account
    end

    # Pinned statuses
    has_many :pinned_statuses, -> { reorder('status_pins.created_at DESC') }, through: :status_pins, class_name: 'Status', source: :status

    # Endorsements
    has_many :endorsed_accounts, through: :account_pins, class_name: 'Account', source: :target_account

    # Lists (that the account is on, not owned by the account)
    has_many :lists, through: :list_accounts

    # Account migrations
    belongs_to :moved_to_account, class_name: 'Account', optional: true

    # Hashtags
    has_and_belongs_to_many :tags # rubocop:disable Rails/HasAndBelongsToMany

    # Follow recommendations
    has_one :follow_recommendation, inverse_of: :account, dependent: nil
    has_one :follow_recommendation_suppression, inverse_of: :account, dependent: :destroy

    # Account statuses cleanup policy
    has_one :statuses_cleanup_policy, class_name: 'AccountStatusesCleanupPolicy', inverse_of: :account, dependent: :destroy

    # Imports
    has_many :bulk_imports, inverse_of: :account, dependent: :delete_all
  end
end
