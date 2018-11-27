class CreateDeletionSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :deletion_schedules do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }
      t.integer :delay, null: false, default: 7.days.seconds

      t.timestamps
    end
  end
end
