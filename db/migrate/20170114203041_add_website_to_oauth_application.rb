# frozen_string_literal: true

class AddWebsiteToOAuthApplication < ActiveRecord::Migration[5.0]
  def change
    add_column :oauth_applications, :website, :string
  end
end
