class MigrateAccountConversations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    # migrated to rake task
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
    Notification.joins(mention: :status).where(activity_type: 'Mention', statuses: { visibility: :direct })
  end
end
