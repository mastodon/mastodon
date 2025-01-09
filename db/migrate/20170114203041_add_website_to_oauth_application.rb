# frozen_string_literal: true

class AddWebsiteToOauthApplication < ActiveRecord::Migration[5.0]
  def change
    add_column :oauth_applications, :website, :string
  end
end
