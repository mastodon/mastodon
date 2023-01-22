keypair     = OpenSSL::PKey::RSA.new(2048)
public_key  = keypair.public_key.to_pem
private_key = keypair.to_pem

Fabricator(:account) do
  transient :suspended, :silenced, :sensitive, :disabled, :unapproved
  username            { sequence(:username) { |i| "#{Faker::Internet.user_name(separators: %w(_))}#{i}" } }
  last_webfingered_at { Time.now.utc }
  public_key          { public_key }
  private_key         { private_key }
  suspended_at        { |attrs| attrs[:suspended] ? Time.now.utc : nil }
  silenced_at         { |attrs| attrs[:silenced] ? Time.now.utc : nil }
  sensitized_at       { |attrs| attrs[:sensitive] ? Time.now.utc : nil }
  discoverable        true
  user do |attrs|
    if attrs[:domain].present?
      nil
    else
      Fabricate.build(:user, account: nil,
                             disabled: attrs[:disabled] == true,
                             approved: !attrs[:unapproved])
    end
  end
end
