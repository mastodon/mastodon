# frozen_string_literal: true

Fabricator(:fasp_provider, from: 'Fasp::Provider') do
  name                    { Faker::App.name }
  base_url                { Faker::Internet.unique.url }
  sign_in_url             { Faker::Internet.url }
  remote_identifier       'MyString'
  provider_public_key_pem "-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAh2ldXsaej2MXj0DHdCx7XibSo66uKlrLfJ5J6hte1Gk=\n-----END PUBLIC KEY-----\n"
  server_private_key_pem  "-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEICDjlajhVb8XfzyTchQWKraMKwtQW+r4opoAg7V3kw1Q\n-----END PRIVATE KEY-----\n"
end

Fabricator(:confirmed_fasp, from: :fasp_provider) do
  confirmed true
  fasp_capabilities do
    [
      Fabricate.build(:fasp_capability, name: 'callback'),
      Fabricate.build(:fasp_capability, name: 'data_sharing'),
    ]
  end
end

Fabricator(:debug_fasp, from: :fasp_provider) do
  confirmed true
  fasp_capabilities do
    [
      Fabricate.build(:fasp_capability, name: 'callback', enabled: true),
    ]
  end

  after_build do |fasp|
    # Prevent fabrication from attempting an HTTP call to the provider
    def fasp.update_remote_capabilities = true
  end
end

Fabricator(:follow_recommendation_fasp, from: :fasp_provider) do
  confirmed true
  fasp_capabilities do
    [
      Fabricate.build(:fasp_capability, name: 'follow_recommendation', enabled: true),
    ]
  end

  after_build do |fasp|
    # Prevent fabrication from attempting an HTTP call to the provider
    def fasp.update_remote_capabilities = true
  end
end

Fabricator(:account_search_fasp, from: :fasp_provider) do
  confirmed true
  fasp_capabilities do
    [
      Fabricate.build(:fasp_capability, name: 'account_search', enabled: true),
    ]
  end

  after_build do |fasp|
    # Prevent fabrication from attempting an HTTP call to the provider
    def fasp.update_remote_capabilities = true
  end
end
