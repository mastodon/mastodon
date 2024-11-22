# frozen_string_literal: true

class AddMetadataToStatuses < ActiveRecord::Migration[4.2]
  def change
    change_table(:statuses, bulk: true) do |t|
      t.column :in_reply_to_id, :integer, null: true
      t.column :reblog_of_id, :integer, null: true
    end
  end
end
