class AddVisibleInPickerToCustomEmoji < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      add_column :custom_emojis, :visible_in_picker, :boolean, default: true, null: false
    }
  end
end
