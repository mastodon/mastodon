# frozen_string_literal: true

class AddBlurhashToSiteUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :site_uploads, :blurhash, :string
  end
end
