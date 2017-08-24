class TruncatePreviewCards < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    # Delete all files first
    PreviewCard.find_each do |card|
      card.image&.destroy
    end

    # Truncate the table
    ActiveRecord::Base.connection.execute('TRUNCATE preview_cards')
  end

  def down; end
end
