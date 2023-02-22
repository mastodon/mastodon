# frozen_string_literal: true

class AddIndexOnMentionsStatusId < ActiveRecord::Migration[5.0]
  def change
    add_index :mentions, :status_id
  end
end
