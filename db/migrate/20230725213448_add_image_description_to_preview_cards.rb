# frozen_string_literal: true

class AddImageDescriptionToPreviewCards < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :preview_cards, :image_description, :string, default: '', null: false }
  end

  def down
    remove_column :preview_cards, :image_description
  end
end
