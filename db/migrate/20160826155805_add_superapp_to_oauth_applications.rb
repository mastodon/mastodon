# frozen_string_literal: true

class AddSuperappToOauthApplications < ActiveRecord::Migration[5.0]
  def change
    add_column :oauth_applications, :superapp, :boolean, default: false, null: false
  end
end
