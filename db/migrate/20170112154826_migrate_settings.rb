# frozen_string_literal: true

class MigrateSettings < ActiveRecord::Migration[4.2]
  def up
    change_table(:settings, bulk: true) do |t|
      t.remove_index [:target_type, :target_id, :var]
      t.rename :target_id, :thing_id
      t.rename :target_type, :thing_type
      t.change :thing_id, :integer, null: true, default: nil
      t.change :thing_type, :string, null: true, default: nil
      t.index [:thing_type, :thing_id, :var], unique: true
    end
  end

  def down
    change_table(:settings, bulk: true) do |t|
      t.remove_index [:thing_type, :thing_id, :var]
      t.rename :thing_id, :target_id
      t.rename :thing_type, :target_type
      t.column :target_id, :integer, null: false # rubocop:disable Rails/NotNullColumn
      t.column :target_type, :string, null: false, default: ''
      t.index [:target_type, :target_id, :var], unique: true
    end
  end
end
