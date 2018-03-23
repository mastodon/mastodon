class RemoveStatusPinsAccountIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :status_pins, :account_id
    remove_index :status_pins, :status_id
  end
end
