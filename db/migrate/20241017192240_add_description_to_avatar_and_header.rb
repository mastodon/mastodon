class AddDescriptionToAvatarAndHeader < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :avatar_description, :string
    add_column :accounts, :header_description, :string
  end
end
