class AddVisibleInPickerToCustomEmoji < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :custom_emojis, :visible_in_picker, :boolean, default: true, null: false
    end
  end
end
