class AddPrivateMessageRecipientId < ActiveRecord::Migration
  def change
    add_column :statuses, :private_recipient_id, :integer, null: true, default: nil
  end
end
