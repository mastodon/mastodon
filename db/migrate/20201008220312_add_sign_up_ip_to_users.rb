class AddSignUpIpToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sign_up_ip, :inet
  end
end
