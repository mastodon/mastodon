class ChangeAccountIdNonnullableInLists < ActiveRecord::Migration[5.1]
  def change
    change_column_null :lists, :account_id, false
  end
end
