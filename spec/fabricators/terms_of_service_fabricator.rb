# frozen_string_literal: true

Fabricator(:terms_of_service) do
  text { Faker::Lorem.paragraph }
  changelog { Faker::Lorem.paragraph }
  published_at { Time.zone.now }
  notification_sent_at { Time.zone.now }
end
