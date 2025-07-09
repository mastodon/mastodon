# frozen_string_literal: true

class AddNotificationSentAtToAnnouncements < ActiveRecord::Migration[8.0]
  def change
    add_column :announcements, :notification_sent_at, :datetime
  end
end
