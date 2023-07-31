class CreateSubscriptionMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_members do |t|
      t.integer :subscription_id
      t.integer :user_id

      t.timestamps
    end
  end
end
