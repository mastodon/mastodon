# frozen_string_literal: true

class ValidateTargetStatusForeignKeyOnPreviewCards < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :preview_cards, column: :target_status_id
  end
end
