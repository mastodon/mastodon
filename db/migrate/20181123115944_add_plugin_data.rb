class AddPluginData < ActiveRecord::Migration[5.2]
  def change
    create_table :plugin_datas do |t|
      t.string :plugin_name, null: false, index: true
      t.jsonb :plugin_data, default: {}, null: false
      t.timestamps
    end
  end
end
