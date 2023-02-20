class CreateAccountsTagsJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :accounts, :tags do |t|
      t.index %i(account_id tag_id)
      t.index %i(tag_id account_id), unique: true
    end
  end
end
