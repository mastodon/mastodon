# frozen_string_literal: true

class AddPreviewCardForeignKeyToStatuses < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :statuses, :preview_cards, on_delete: :nullify, validate: false
  end
end
