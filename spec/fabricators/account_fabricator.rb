# frozen_string_literal: true

Fabricator(:account) do
  transient :suspended, :silenced
  username            { sequence(:username) { |i| "#{Faker::Internet.user_name(separators: %w(_))}#{i}" } }
  last_webfingered_at { Time.now.utc }
  public_key          { SigningKeysHelpers::PUBLIC_RSA_TEST_KEY }
  private_key         { |attrs| attrs[:domain].present? ? nil : SigningKeysHelpers::PRIVATE_RSA_TEST_KEY }
  suspended_at        { |attrs| attrs[:suspended] ? Time.now.utc : nil }
  silenced_at         { |attrs| attrs[:silenced] ? Time.now.utc : nil }
  user                { |attrs| attrs[:domain].nil? ? Fabricate.build(:user, account: nil) : nil }
  uri                 { |attrs| attrs[:domain].nil? ? '' : "https://#{attrs[:domain]}/users/#{attrs[:username]}" }
  discoverable        true
  indexable           true
end

Fabricator(:remote_account, from: :account) do
  domain 'example.com'
end
