Fabricator(:webhook) do
  url { Faker::Internet.url }
  secret { SecureRandom.hex }
  events { Webhook::EVENTS }
end
