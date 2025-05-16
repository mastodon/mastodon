# frozen_string_literal: true

class AddAvatarMetaToAccounts < ActiveRecord::Migration[8.0]
  def change
    safety_assured { add_column :accounts, :meta, :json }
    add_column :accounts, :blurhash, :string
  end
end
