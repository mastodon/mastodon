# frozen_string_literal: true

Fabricator(:preview_card) do
  url { Faker::Internet.url }
  title { Faker::Lorem.sentence }
  description { Faker::Lorem.paragraph }
  type 'link'
  image { attachment_fixture('attachment.jpg') }
end
