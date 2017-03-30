class AddCounterCaches < ActiveRecord::Migration[5.0]
  def change
  	add_column :statuses, :favourites_count, :integer
  	add_column :statuses, :reblogs_count, :integer

  	execute('update statuses set favourites_count = (select count(*) from favourites where favourites.status_id = statuses.id), reblogs_count = (select count(*) from statuses as reblogs where reblogs.reblog_of_id = statuses.id)')

  	add_column :accounts, :statuses_count, :integer
  	add_column :accounts, :followers_count, :integer
  	add_column :accounts, :following_count, :integer

  	execute('update accounts set statuses_count = (select count(*) from statuses where account_id = accounts.id), followers_count = (select count(*) from follows where target_account_id = accounts.id), following_count = (select count(*) from follows where account_id = accounts.id)')
  end
end
