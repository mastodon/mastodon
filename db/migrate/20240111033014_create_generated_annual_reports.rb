# frozen_string_literal: true

class CreateGeneratedAnnualReports < ActiveRecord::Migration[7.1]
  def change
    create_table :generated_annual_reports do |t|
      t.belongs_to :account, null: false, foreign_key: { on_cascade: :delete }, index: false
      t.integer :year, null: false
      t.jsonb :data, null: false
      t.integer :schema_version, null: false
      t.datetime :viewed_at

      t.timestamps
    end

    add_index :generated_annual_reports, [:account_id, :year], unique: true
  end
end
