class CreateStatusCapabilityTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :status_capability_tokens do |t|
      t.belongs_to :status, foreign_key: true
      t.string :token

      t.timestamps
    end
  end
end
