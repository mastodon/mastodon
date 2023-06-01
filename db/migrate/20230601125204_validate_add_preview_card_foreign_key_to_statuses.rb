# frozen_string_literal: true

class ValidateAddPreviewCardForeignKeyToStatuses < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :statuses, :preview_cards
  end
end
