Fabricator(:user) do
  account
  email        "alice@example.com"
  password     "123456789"
  confirmed_at { Time.now }
end
