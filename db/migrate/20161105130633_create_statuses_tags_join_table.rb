# frozen_string_literal: true

class CreateStatusesTagsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_join_table :statuses, :tags do |t|
      t.index :tag_id
      t.index [:tag_id, :status_id], unique: true
    end
  end
end
