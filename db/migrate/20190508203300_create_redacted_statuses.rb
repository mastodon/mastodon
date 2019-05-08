class CreateRedactedStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :redacted_statuses do |t|
      t.int :id
      t.references :account, foreign_key: true
      t.string :uri

      t.timestamps
    end
  end
end
