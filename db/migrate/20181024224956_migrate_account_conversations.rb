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

    total        = estimate_rows(local_direct_statuses) + estimate_rows(notifications_about_direct_statuses)
    migrated     = 0
    started_time = Time.zone.now
    last_time    = Time.zone.now

    local_direct_statuses.includes(:account, mentions: :account).find_each do |status|
      AccountConversation.add_status(status.account, status)
      migrated += 1

      if Time.zone.now - last_time > 1
        say_progress(migrated, total, started_time)
        last_time = Time.zone.now
      end
    end

    notifications_about_direct_statuses.includes(:account, mention: { status: [:account, mentions: :account] }).find_each do |notification|
      AccountConversation.add_status(notification.account, notification.target_status)
      migrated += 1

      if Time.zone.now - last_time > 1
        say_progress(migrated, total, started_time)
        last_time = Time.zone.now
      end
    end
  end

  def down
  end

  private

  def estimate_rows(query)
    result = exec_query("EXPLAIN #{query.to_sql}").first
    result['QUERY PLAN'].scan(/ rows=([\d]+)/).first&.first&.to_i || 0
  end

  def say_progress(migrated, total, started_time)
    status = "Migrated #{migrated} rows"

    percentage = 100.0 * migrated / total
    status += " (~#{sprintf('%.2f', percentage)}%, "

    remaining_time = (100.0 - percentage) * (Time.zone.now - started_time) / percentage

    status += "#{(remaining_time / 60).to_i}:"
    status += sprintf('%02d', remaining_time.to_i % 60)
    status += ' remaining)'

    say status, true
  end

  def local_direct_statuses
    Status.unscoped.local.where(visibility: :direct)
  end

  def notifications_about_direct_statuses
    Notification.joins(mention: :status).where(activity_type: 'Mention', statuses: { visibility: :direct })
  end
end
