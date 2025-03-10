# frozen_string_literal: true

Fabricator(:webhook) do
  url { sequence(:url) { |i| "https://host.example/pages/#{i}" } }
  secret { SecureRandom.hex }
  events { Webhook::EVENTS }
end
