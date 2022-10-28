class AddLanguagesToFollowRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :follow_requests, :languages, :string, array: true
  end
end
