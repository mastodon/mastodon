# frozen_string_literal: true

class AddSuperappIndexToApplications < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :oauth_applications, :superapp, where: 'superapp = true', algorithm: :concurrently
  end
end
