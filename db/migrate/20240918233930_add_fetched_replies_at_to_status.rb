# frozen_string_literal: true

class AddFetchedRepliesAtToStatus < ActiveRecord::Migration[7.1]
  def change
    add_column :statuses, :fetched_replies_at, :datetime, null: true
  end
end
