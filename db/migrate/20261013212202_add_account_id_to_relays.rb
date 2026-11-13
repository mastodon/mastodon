# frozen_string_literal: true

class AddAccountIdToRelays < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    safety_assured { add_reference :relays, :account, foreign_key: { on_delete: :cascade }, index: false }
  end
end
