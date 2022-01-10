class AddBlockSynchroListToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :block_synchro_list, :string
  end
end
