# frozen_string_literal: true

class AddTargetStatusForeignKeyToPreviewCards < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :preview_cards, :statuses, column: :target_status_id, on_delete: :cascade, validate: false
  end
end
