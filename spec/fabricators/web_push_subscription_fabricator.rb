Fabricator(:web_push_subscription) do
  endpoint   Faker::Internet.url
  key_p256dh Faker::Internet.password
  key_auth   Faker::Internet.password
end
