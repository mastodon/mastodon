# frozen_string_literal: true

class AddLanguageToPreviewCards < ActiveRecord::Migration[6.1]
  def change
    add_column :preview_cards, :language, :string
    add_column :preview_cards, :max_score, :float
    add_column :preview_cards, :max_score_at, :datetime
  end
end
