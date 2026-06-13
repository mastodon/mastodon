# frozen_string_literal: true

keypair     = OpenSSL::PKey::RSA.new(2048)
public_key  = keypair.public_key.to_pem
private_key = keypair.to_pem

Fabricator(:account_base, class_name: :account) do
  transient :suspended, :silenced, :legacy_keypair
  username            { sequence(:username) { |i| "#{Faker::Internet.user_name(separators: %w(_))}#{i}" } }
  last_webfingered_at { Time.now.utc }
  public_key          { |attrs| attrs[:legacy_keypair] ? public_key : '' }
  private_key         { |attrs| attrs[:legacy_keypair] ? private_key : nil }
  suspended_at        { |attrs| attrs[:suspended] ? Time.now.utc : nil }
  silenced_at         { |attrs| attrs[:silenced] ? Time.now.utc : nil }
  user                { |attrs| attrs[:domain].nil? ? Fabricate.build(:user, account: nil) : nil }
  uri                 { |attrs| attrs[:domain].nil? ? '' : "https://#{attrs[:domain]}/users/#{attrs[:username]}" }
  discoverable        true
  indexable           true
end

Fabricator(:account, from: :account_base) do
  after_create do |account|
    account.keypairs = [Fabricate.build(:keypair, account: account)] if account.keypairs.blank? && account.public_key.blank? && account.private_key.blank?
  end
end

Fabricator(:account_with_private_key, from: :account_base) do
  after_create do |account|
    account.keypairs = [Fabricate.build(:keypair, account: account, require_private_key: true)] if account.keypairs.blank? && account.public_key.blank? && account.private_key.blank?
  end
end

Fabricator(:remote_account, from: :account) do
  domain 'example.com'
end
