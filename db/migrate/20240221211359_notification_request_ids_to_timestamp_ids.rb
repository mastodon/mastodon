# frozen_string_literal: true

class NotificationRequestIdsToTimestampIds < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute("ALTER TABLE notification_requests ALTER COLUMN id SET DEFAULT timestamp_id('notification_requests')")
    end
  end

  def down
    execute('LOCK notification_requests')
    execute("SELECT setval('notification_requests_id_seq', (SELECT MAX(id) FROM notification_requests))")
    execute("ALTER TABLE notification_requests ALTER COLUMN id SET DEFAULT nextval('notification_requests_id_seq')")
  end
end
