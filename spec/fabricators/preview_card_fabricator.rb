# frozen_string_literal: true

Fabricator(:preview_card) do
  transient :image_remote_url

  url { Faker::Internet.url }
  title { Faker::Lorem.sentence }
  description { Faker::Lorem.paragraph }
  type 'link'
  image { attachment_fixture('attachment.jpg') }

  after_build { |preview_card, transients| preview_card[:image_remote_url] = transients[:image_remote_url] }
end
