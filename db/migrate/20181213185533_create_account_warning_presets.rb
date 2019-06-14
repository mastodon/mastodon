class CreateAccountWarningPresets < ActiveRecord::Migration[5.2]
  def change
    create_table :account_warning_presets do |t|
      t.text :text, null: false, default: ''

      t.timestamps
    end
  end
end
