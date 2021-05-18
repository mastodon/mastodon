class DefaultAccountLockedToTrue < ActiveRecord::Migration[6.1]
  def change
    change_column_default :accounts, :locked, from: false, to: true
  end
end
