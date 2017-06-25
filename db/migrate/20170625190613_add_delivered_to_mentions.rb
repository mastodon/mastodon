class AddDeliveredToMentions < ActiveRecord::Migration[5.0]
  def change
    add_column :mentions, :delivered, :boolean, null: true, default: nil
  end
end
