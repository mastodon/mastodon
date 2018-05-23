ActiveRecord::Schema.define version: 0 do
  create_table "documents", force: true do |t|
    t.string :owner
    t.string :video_file_name
    t.string :video_content_type
    t.integer :video_updated_at
    t.integer :video_file_size
    t.string :image_file_name
    t.string :image_content_type
    t.integer :image_updated_at
    t.integer :image_file_size
  end
end