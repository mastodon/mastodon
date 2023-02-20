Fabricator(:custom_emoji) do
  shortcode 'coolcat'
  domain    nil
  image     { Rails.root.join('spec', 'fixtures', 'files', 'emojo.png').open }
end
