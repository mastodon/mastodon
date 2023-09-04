class AddHiddenToStreamEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :stream_entries, :hidden, :boolean, null: false, default: false
  end
end
