# frozen_string_literal: true

class RemoveDuplicateFaspCapabilitiesProviderIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :fasp_capabilities, :fasp_provider_id
  end
end
