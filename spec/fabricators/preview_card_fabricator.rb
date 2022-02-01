Fabricator(:preview_card) do
  url { Faker::Internet.url }
  title { Faker::Lorem.sentence }
  description { Faker::Lorem.paragraph }
  type 'link'
end
