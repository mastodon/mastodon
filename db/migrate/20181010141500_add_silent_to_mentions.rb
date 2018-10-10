class AddSilentToMentions < ActiveRecord::Migration[5.2]
  def change
    add_column :mentions, :silent, :boolean, null: true, default: nil
  end
end
