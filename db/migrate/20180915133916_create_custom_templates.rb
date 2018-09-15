class CreateCustomTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_templates do |t|
      t.text :content, null: false
      t.boolean :disabled, null: false, default: false

      t.timestamps
    end
  end
end
