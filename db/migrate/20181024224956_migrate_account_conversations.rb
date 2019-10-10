class MigrateAccountConversations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    say ''
    say 'WARNING: This migration may take a *long* time for large instances'
    say 'It will *not* lock tables for any significant time, but it may run'
    say 'for a very long time. We will pause for 10 seconds to allow you to'
    say 'interrupt this migration if you are not ready.'
    say ''

    10.downto(1) do |i|
      say "Continuing in #{i} second#{i == 1 ? '' : 's'}...", true
      sleep 1
    end

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

  def down
  end

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
