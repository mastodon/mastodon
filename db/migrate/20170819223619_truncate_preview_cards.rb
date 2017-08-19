class TruncatePreviewCards < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.connection.execute('TRUNCATE preview_cards')
      end
    end

    remove_column :preview_cards, :status_id, :integer
    add_index :preview_cards, :url, unique: true
  end
end
