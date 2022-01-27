Fabricator(:user) do
  account      { Fabricate.build(:account, user: nil) }
  email        { sequence(:email) { |i| "#{i}#{Faker::Internet.email}" } }
  password     "123456789"
  confirmed_at { Time.zone.now }
  agreement    true
end
