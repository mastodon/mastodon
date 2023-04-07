class AddInviteIdToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured { add_reference :users, :invite, null: true, default: nil, foreign_key: { on_delete: :nullify }, index: false }
  end
end
