# frozen_string_literal: true

Fabricator(:fasp_provider, from: 'Fasp::Provider') do
  name                    { Faker::App.name }
  base_url                { Faker::Internet.unique.url }
  sign_in_url             { Faker::Internet.url }
  remote_identifier       'MyString'
  provider_public_key_pem 'MyString'
  capabilities            []
end
