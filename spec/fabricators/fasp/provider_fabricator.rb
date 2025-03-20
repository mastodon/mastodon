# frozen_string_literal: true

Fabricator(:fasp_provider, from: 'Fasp::Provider') do
  name                    { Faker::App.name }
  base_url                { Faker::Internet.unique.url }
  sign_in_url             { Faker::Internet.url }
  remote_identifier       'MyString'
  provider_public_key_pem "-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAh2ldXsaej2MXj0DHdCx7XibSo66uKlrLfJ5J6hte1Gk=\n-----END PUBLIC KEY-----\n"
  server_private_key_pem  "-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEICDjlajhVb8XfzyTchQWKraMKwtQW+r4opoAg7V3kw1Q\n-----END PRIVATE KEY-----\n"
  capabilities            []
end

Fabricator(:confirmed_fasp, from: :fasp_provider) do
  confirmed    true
  capabilities [
    { id: 'debug', version: '0.1' },
    { id: 'data_sharing', version: '0.1' },
  ]
end
