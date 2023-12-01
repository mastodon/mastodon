# frozen_string_literal: true

class AddReplyToStatuses < ActiveRecord::Migration[5.0]
  def up
    add_column :statuses, :reply, :boolean, nil: false, default: false
    Status.unscoped.update_all('reply = (in_reply_to_id IS NOT NULL)')
  end

  def down
    remove_column :statuses, :reply
  end
end
