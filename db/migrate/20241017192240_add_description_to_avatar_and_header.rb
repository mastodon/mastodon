# frozen_string_literal: true

class AddDescriptionToAvatarAndHeader < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :avatar_description, :string, default: ''
    add_column :accounts, :header_description, :string, default: ''
  end
end
