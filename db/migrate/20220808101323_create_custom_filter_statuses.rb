# frozen_string_literal: true

class CreateCustomFilterStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :custom_filter_statuses do |t|
      t.belongs_to :custom_filter, foreign_key: { on_delete: :cascade }, null: false
      t.belongs_to :status, foreign_key: { on_delete: :cascade }, null: false

      t.timestamps
    end
  end
end
