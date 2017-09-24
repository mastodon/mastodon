class IdsToBigints6 < ActiveRecord::Migration[5.1]
  def up
    change_column :favourites, :account_id, :bigint
    change_column :favourites, :id, :bigint
    change_column :favourites, :status_id, :bigint
  end

  def down
    change_column :favourites, :account_id, :integer
    change_column :favourites, :id, :integer
    change_column :favourites, :status_id, :integer
  end
end
