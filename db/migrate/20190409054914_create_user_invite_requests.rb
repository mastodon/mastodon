class CreateUserInviteRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :user_invite_requests do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }
      t.text :text

      t.timestamps
    end
  end
end
