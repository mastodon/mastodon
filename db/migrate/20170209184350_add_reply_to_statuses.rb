# frozen_string_literal: true

class AddReplyToStatuses < ActiveRecord::Migration[5.0]
  def up
    add_column :statuses, :reply, :boolean, default: false # rubocop:disable Rails/ThreeStateBooleanColumn
    Status.unscoped.update_all('reply = (in_reply_to_id IS NOT NULL)')
  end

  def down
    remove_column :statuses, :reply
  end
end
