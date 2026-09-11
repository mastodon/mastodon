# frozen_string_literal: true

class AddLocalFragmentToKeypair < ActiveRecord::Migration[8.1]
  def change
    add_column :keypairs, :local_fragment, :string, null: true
  end
end
