class AddTankerIdentitiesToUsers < ActiveRecord::Migration[5.2]
  def change
      add_column :users, :tanker_identity, :string
  end
end
