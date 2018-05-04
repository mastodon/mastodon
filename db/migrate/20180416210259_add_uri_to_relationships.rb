class AddUriToRelationships < ActiveRecord::Migration[5.2]
  def change
    add_column :follows, :uri, :string
    add_column :follow_requests, :uri, :string
    add_column :blocks, :uri, :string
  end
end
