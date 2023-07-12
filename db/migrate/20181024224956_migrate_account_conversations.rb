# frozen_string_literal: true

require_relative '../../lib/mastodon/migration_warning'

class MigrateAccountConversations < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationWarning

  disable_ddl_transaction!

  class Mention < ApplicationRecord
    belongs_to :account, inverse_of: :mentions
    belongs_to :status, -> { unscope(where: :deleted_at) }

    delegate(
      :username,
      :acct,
      to: :account,
      prefix: true
    )
  end

  class Notification < ApplicationRecord
    belongs_to :account, optional: true
    belongs_to :activity, polymorphic: true, optional: true

    belongs_to :status,  foreign_key: 'activity_id', optional: true
    belongs_to :mention, foreign_key: 'activity_id', optional: true

    def target_status
      mention&.status
    end
  end

  class AccountConversation < ApplicationRecord
    belongs_to :account
    belongs_to :conversation
    belongs_to :last_status, -> { unscope(where: :deleted_at) }, class_name: 'Status'

    before_validation :set_last_status

    class << self
      def add_status(recipient, status)
        conversation = find_or_initialize_by(account: recipient, conversation_id: status.conversation_id, participant_account_ids: participants_from_status(recipient, status))

        return conversation if conversation.status_ids.include?(status.id)

        conversation.status_ids << status.id
        conversation.unread = status.account_id != recipient.id
        conversation.save
        conversation
      rescue ActiveRecord::StaleObjectError
        retry
      end

      private

      def participants_from_status(recipient, status)
        ((status.active_mentions.pluck(:account_id) + [status.account_id]).uniq - [recipient.id]).sort
      end
    end

    private

    def set_last_status
      self.status_ids     = status_ids.sort
      self.last_status_id = status_ids.last
    end
  end

  def up
    migration_duration_warning

    migrated  = 0
    last_time = Time.zone.now

    local_direct_statuses.includes(:account, mentions: :account).find_each do |status|
      AccountConversation.add_status(status.account, status)
      migrated += 1

      if Time.zone.now - last_time > 1
        say_progress(migrated)
        last_time = Time.zone.now
      end
    end

    notifications_about_direct_statuses.includes(:account, mention: { status: [:account, mentions: :account] }).find_each do |notification|
      AccountConversation.add_status(notification.account, notification.target_status)
      migrated += 1

      if Time.zone.now - last_time > 1
        say_progress(migrated)
        last_time = Time.zone.now
      end
    end
  end

  def down; end

  private

  def say_progress(migrated)
    say "Migrated #{migrated} rows", true
  end

  def local_direct_statuses
    Status.unscoped.local.where(visibility: :direct)
  end

  def notifications_about_direct_statuses
    Notification.joins('INNER JOIN mentions ON mentions.id = notifications.activity_id INNER JOIN statuses ON statuses.id = mentions.status_id').where(activity_type: 'Mention', statuses: { visibility: :direct })
  end
end
