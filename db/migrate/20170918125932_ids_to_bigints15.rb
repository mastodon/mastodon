class IdsToBigints15 < ActiveRecord::Migration[5.1]
  def up
    change_column :oauth_access_tokens, :application_id, :bigint
    change_column :oauth_access_tokens, :id, :bigint
    change_column :oauth_access_tokens, :resource_owner_id, :bigint
  end

  def down
    change_column :oauth_access_tokens, :application_id, :integer
    change_column :oauth_access_tokens, :id, :integer
    change_column :oauth_access_tokens, :resource_owner_id, :integer
  end
end
