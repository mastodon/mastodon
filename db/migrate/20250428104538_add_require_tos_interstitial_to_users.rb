# frozen_string_literal: true

class AddRequireTosInterstitialToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :require_tos_interstitial, :boolean, null: false, default: false
  end
end
