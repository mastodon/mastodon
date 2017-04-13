Fabricator(:user) do
  account
  email        { Faker::Internet.email }
  password     "123456789"
  confirmed_at { Time.now }
end
