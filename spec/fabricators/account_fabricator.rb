# frozen_string_literal: true

keypair     = OpenSSL::PKey::RSA.new(2048)
public_key  = keypair.public_key.to_pem
private_key = keypair.to_pem

Fabricator(:account) do
  transient :suspended, :silenced
  username            { sequence(:username) { |i| "#{Faker::Internet.user_name(separators: %w(_))}#{i}" } }
  last_webfingered_at { Time.now.utc }
  public_key          { public_key }
  private_key         { private_key }
  suspended_at        { |attrs| attrs[:suspended] ? Time.now.utc : nil }
  silenced_at         { |attrs| attrs[:silenced] ? Time.now.utc : nil }
  user                { |attrs| attrs[:domain].nil? ? Fabricate.build(:user, account: nil) : nil }
  uri                 { |attrs| attrs[:domain].nil? ? '' : "https://#{attrs[:domain]}/users/#{attrs[:username]}" }
  discoverable        true
end
