Fabricator(:custom_emoji) do
  shortcode         'coolcat'
  domain            nil
  disabled          false
  visible_in_picker true
  image             { Rails.root.join('spec/fixtures/files/emojo.png').open }
end
