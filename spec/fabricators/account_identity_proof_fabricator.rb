Fabricator(:account_identity_proof) do
  account
  provider 'Keybase'
  provider_username { sequence(:provider_username) { |i| "#{Faker::Lorem.characters(15)}" } }
  token { sequence(:token) { |i| "#{i}#{Faker::Crypto.sha1()*2}"[0..65] } }
  is_valid nil
  is_live nil
end
