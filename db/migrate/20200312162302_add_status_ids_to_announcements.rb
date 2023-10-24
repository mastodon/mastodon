# frozen_string_literal: true

class AddStatusIdsToAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :announcements, :status_ids, :bigint, array: true
  end
end
