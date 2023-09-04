class CreatePgheroSpaceStats < ActiveRecord::Migration[5.2]
  def change
    create_table :pghero_space_stats do |t|
      t.text :database
      t.text :schema
      t.text :relation
      t.integer :size, limit: 8
      t.timestamp :captured_at
    end

    add_index :pghero_space_stats, [:database, :captured_at]
  end
end
