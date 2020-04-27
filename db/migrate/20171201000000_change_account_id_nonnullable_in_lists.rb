class ChangeAccountIdNonnullableInLists < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column_null :lists, :account_id, false
    end
  end
end
