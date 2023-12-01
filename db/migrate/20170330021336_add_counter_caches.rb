# frozen_string_literal: true

class AddCounterCaches < ActiveRecord::Migration[5.0]
  def change
    change_table(:statuses, bulk: true) do |t|
      t.column :favourites_count, :integer, null: false, default: 0
      t.column :reblogs_count, :integer, null: false, default: 0
    end
    change_table(:accounts, bulk: true) do |t|
      t.column :statuses_count, :integer, null: false, default: 0
      t.column :followers_count, :integer, null: false, default: 0
      t.column :following_count, :integer, null: false, default: 0
    end
  end
end

# To make the new fields contain correct data:
# update statuses set favourites_count = (select count(*) from favourites where favourites.status_id = statuses.id), reblogs_count = (select count(*) from statuses as reblogs where reblogs.reblog_of_id = statuses.id);
# update accounts set statuses_count = (select count(*) from statuses where account_id = accounts.id), followers_count = (select count(*) from follows where target_account_id = accounts.id), following_count = (select count(*) from follows where account_id = accounts.id);
