Fabricator(:user) do
  account
  email        { sequence(:email) { |i| "#{i}#{Faker::Internet.email}" } }
  password     "123456789"
  confirmed_at { Time.now }
end
