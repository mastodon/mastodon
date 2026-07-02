# frozen_string_literal: true

Fabricator(:account) do
  transient :suspended, :silenced, :legacy_keypair
  username            { sequence(:username) { |i| "#{Faker::Internet.user_name(separators: %w(_))}#{i}" } }
  last_webfingered_at { Time.now.utc }
  public_key          { |attrs| attrs[:legacy_keypair] ? SigningKeysHelpers::PUBLIC_RSA_TEST_KEY : '' }
  private_key         { |attrs| attrs[:legacy_keypair] && attrs[:domain].nil? ? SigningKeysHelpers::PRIVATE_RSA_TEST_KEY : nil }
  suspended_at        { |attrs| attrs[:suspended] ? Time.now.utc : nil }
  silenced_at         { |attrs| attrs[:silenced] ? Time.now.utc : nil }
  user                { |attrs| attrs[:domain].nil? ? Fabricate.build(:user, account: nil) : nil }
  uri                 { |attrs| attrs[:domain].nil? ? '' : "https://#{attrs[:domain]}/users/#{attrs[:username]}" }
  discoverable        true
  indexable           true

  # This is not strictly needed but this avoids generating multiple keys
  # and, when `store_private_key` is passed, stores private keys for use in request specs
  keypairs do |attrs|
    if attrs[:legacy_keypair] || attrs[:public_key].present?
      []
    else
      [
        Keypair.new(
          type: :rsa,
          public_key: SigningKeysHelpers::PUBLIC_RSA_TEST_KEY,
          private_key: attrs[:domain].blank? ? SigningKeysHelpers::PRIVATE_RSA_TEST_KEY : nil,
          uri: attrs[:domain].nil? ? nil : "https://#{attrs[:domain]}/users/#{attrs[:username]}#main-key",
          local_fragment: attrs[:domain].nil? ? '#main-key' : nil
        ),
      ]
    end
  end
end

Fabricator(:remote_account, from: :account) do
  domain 'example.com'
end
