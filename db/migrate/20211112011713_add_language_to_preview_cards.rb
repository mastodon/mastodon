class AddLanguageToPreviewCards < ActiveRecord::Migration[6.1]
  def change
    change_table :preview_cards, bulk: true do |t|
      t.column :language, :string
      t.column :max_score, :float
      t.column :max_score_at, :datetime
    end
  end
end
