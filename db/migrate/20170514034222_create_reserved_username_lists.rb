class CreateReservedUsernameLists < ActiveRecord::Migration[5.0]
  def change
    create_table :reserved_username_lists do |t|
      t.string :word
    end
  end
end
