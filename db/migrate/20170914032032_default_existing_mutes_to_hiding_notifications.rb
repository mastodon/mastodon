class DefaultExistingMutesToHidingNotifications < ActiveRecord::Migration[5.1]
  def up
    t.change_column_default :mutes, :hide_notifications, from: false, to: true

    # Unfortunately if this is applied sometime after the one to add the table we lose some data, so this is irreversible.
    Mutes.update_all(hide_notifications: true)
  end
end
