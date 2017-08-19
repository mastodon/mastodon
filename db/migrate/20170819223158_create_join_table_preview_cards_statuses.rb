class CreateJoinTablePreviewCardsStatuses < ActiveRecord::Migration[5.1]
  def change
    create_join_table :preview_cards, :statuses do |t|
      t.index [:status_id, :preview_card_id]
    end
  end
end
