# frozen_string_literal: true

Fabricator(:terms_of_service) do
  text { 'Terms of service text' }
  changelog { 'Terms of service changelog text' }
  published_at { Time.zone.now }
  notification_sent_at { Time.zone.now }
  effective_date { sequence(:effective_date) { |i| i.days.from_now } }
end
