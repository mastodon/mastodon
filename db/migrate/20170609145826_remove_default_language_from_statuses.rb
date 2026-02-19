# frozen_string_literal: true

class RemoveDefaultLanguageFromStatuses < ActiveRecord::Migration[5.1]
  def up
    change_column :statuses, :language, :string, default: nil, null: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
