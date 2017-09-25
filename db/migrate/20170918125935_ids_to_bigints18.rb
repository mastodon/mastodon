class IdsToBigints18 < ActiveRecord::Migration[5.1]
  def up
    change_column :session_activations, :access_token_id, :bigint
    change_column :session_activations, :user_id, :bigint
    change_column :session_activations, :web_push_subscription_id, :bigint
  end

  def down
    change_column :session_activations, :access_token_id, :integer
    change_column :session_activations, :user_id, :integer
    change_column :session_activations, :web_push_subscription_id, :integer
  end
end
