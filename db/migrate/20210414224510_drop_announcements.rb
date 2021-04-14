class DropAnnouncements < ActiveRecord::Migration[5.2]
  def change
    drop_table :announcement_links
    drop_table :announcements
  end
end
