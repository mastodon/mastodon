# frozen_string_literal: true

Fabricator(:tagged_object) do
  status
  object  nil
  ap_type 'FeaturedCollection'
  uri     { Faker::Internet.device_token }
end
