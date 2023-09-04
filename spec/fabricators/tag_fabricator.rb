Fabricator(:tag) do
  name { sequence(:hashtag) { |i| "#{Faker::Lorem.word}#{i}" } }
end
