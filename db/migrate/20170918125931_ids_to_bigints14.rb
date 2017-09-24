class IdsToBigints14 < ActiveRecord::Migration[5.1]
  def up
    change_column :oauth_access_grants, :application_id, :bigint
    change_column :oauth_access_grants, :id, :bigint
    change_column :oauth_access_grants, :resource_owner_id, :bigint
  end

  def down
    change_column :oauth_access_grants, :application_id, :integer
    change_column :oauth_access_grants, :id, :integer
    change_column :oauth_access_grants, :resource_owner_id, :integer
  end
end
