class CreateStreamEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :stream_entries do |t|
      t.integer :account_id
      t.integer :activity_id
      t.string :activity_type

      t.timestamps null: false
    end
  end
end
