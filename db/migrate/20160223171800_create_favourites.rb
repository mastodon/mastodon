class CreateFavourites < ActiveRecord::Migration[4.2]
  def change
    create_table :favourites do |t|
      t.integer :account_id, null: false
      t.integer :status_id, null: false

      t.timestamps null: false
    end

    add_index :favourites, [:account_id, :status_id], unique: true
  end
end
