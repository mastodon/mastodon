# frozen_string_literal: true

class AddTargetAccountIdToPreviewCards < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_belongs_to :preview_cards, :target_account, null: true, index: { algorithm: :concurrently, where: 'target_account_id IS NOT NULL' }
  end
end
