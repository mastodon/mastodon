Fabricator(:appeal) do
  strike(fabricator: :account_warning)
  account { |attrs| attrs[:strike].target_account }
  text { Faker::Lorem.paragraph }
end
