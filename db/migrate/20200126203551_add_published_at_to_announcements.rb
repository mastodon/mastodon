# frozen_string_literal: true

class AddPublishedAtToAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :announcements, :published_at, :datetime
  end
end
