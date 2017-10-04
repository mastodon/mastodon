Fabricator(:custom_emoji_icon) do
  image { File.open(Rails.root.join('spec', 'fixtures', 'files', 'emojo.png')) }
end
