class AddCounterCaches < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :favourites_count, :integer
    add_column :statuses, :reblogs_count, :integer
    add_column :accounts, :statuses_count, :integer
    add_column :accounts, :followers_count, :integer
    add_column :accounts, :following_count, :integer
  end
end
