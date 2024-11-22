# frozen_string_literal: true

class AddEmbedURLToPreviewCards < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :preview_cards, :embed_url, :string, default: '', null: false
    end
  end

  def down
    execute "UPDATE preview_cards SET url=embed_url WHERE embed_url!=''"
    remove_column :preview_cards, :embed_url
  end
end
