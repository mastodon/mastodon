# frozen_string_literal: true

class AddImageRemoteURLToPreviewCards < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :preview_cards, :image_remote_url, :string }
  end

  def down
    remove_column :preview_cards, :image_remote_url
  end
end
