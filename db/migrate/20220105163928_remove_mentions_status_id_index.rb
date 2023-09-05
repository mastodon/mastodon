# frozen_string_literal: true

class RemoveMentionsStatusIdIndex < ActiveRecord::Migration[6.1]
  def up
    remove_index :mentions, name: :mentions_status_id_index if index_exists?(:mentions, :status_id, name: :mentions_status_id_index)
  end

  def down
    # As this index should not exist and is a duplicate of another index, do not re-create it
  end
end
