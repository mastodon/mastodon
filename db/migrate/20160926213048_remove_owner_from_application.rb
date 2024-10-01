# frozen_string_literal: true

class RemoveOwnerFromApplication < ActiveRecord::Migration[5.0]
  def change
    change_table(:oauth_applications, bulk: true) do |t|
      t.remove_index [:owner_id, :owner_type]
      t.remove :owner_id, type: :integer, options: { null: true }
      t.remove :owner_type, type: :string, options: { null: true }
    end
  end
end
