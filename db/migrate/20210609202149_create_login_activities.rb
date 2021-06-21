class CreateLoginActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :login_activities do |t|
      t.belongs_to :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :authentication_method
      t.string :provider
      t.boolean :success
      t.string :failure_reason
      t.inet :ip
      t.string :user_agent
      t.datetime :created_at
    end
  end
end
