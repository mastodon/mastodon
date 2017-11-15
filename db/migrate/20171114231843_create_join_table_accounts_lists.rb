class CreateJoinTableAccountsLists < ActiveRecord::Migration[5.1]
  def change
    create_join_table :accounts, :lists do |t|
      t.index [:account_id, :list_id], unique: true
      t.index [:list_id, :account_id]
    end
  end
end
