class CreateCthulhus < ActiveRecord::Migration[5.2]
  def change
    create_table :cthulhus do |t|

      t.timestamps
    end
  end
end
