class AddLdapDnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ldap_dn, :text, null: true, default: nil
    add_index :users, :ldap_dn
  end
end
