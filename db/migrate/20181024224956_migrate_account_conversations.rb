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

    local_direct_statuses.find_each do |status|
      AccountConversation.add_status(status.account, status)
    end

    notifications_about_direct_statuses.find_each do |notification|
      AccountConversation.add_status(notification.account, notification.target_status)
    end
  end

  def down
  end

  private

  def local_direct_statuses
    Status.unscoped
          .local
          .where(visibility: :direct)
          .includes(:account, mentions: :account)
  end

  def notifications_about_direct_statuses
    Notification.joins(mention: :status)
                .where(activity_type: 'Mention', statuses: { visibility: :direct })
                .includes(:account, mention: { status: [:account, mentions: :account] })
  end
end
