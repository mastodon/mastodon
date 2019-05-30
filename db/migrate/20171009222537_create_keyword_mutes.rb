class CreateKeywordMutes < ActiveRecord::Migration[5.1]
  def change
    create_table :keyword_mutes do |t|
      t.references :account, null: false
      t.string :keyword, null: false
      t.boolean :whole_word, null: false, default: true
      t.timestamps
    end

    safety_assured { add_foreign_key :keyword_mutes, :accounts, on_delete: :cascade }
  end
end
