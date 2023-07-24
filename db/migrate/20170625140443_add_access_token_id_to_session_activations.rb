# frozen_string_literal: true

class AddAccessTokenIdToSessionActivations < ActiveRecord::Migration[5.1]
  def change
    add_column :session_activations, :access_token_id, :integer
    add_foreign_key :session_activations, :oauth_access_tokens, column: :access_token_id, on_delete: :cascade
  end
end
