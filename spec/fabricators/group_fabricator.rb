keypair     = OpenSSL::PKey::RSA.new(2048)
public_key  = keypair.public_key.to_pem
private_key = keypair.to_pem

Fabricator(:group) do
  transient :suspended
  public_key          { public_key }
  private_key         { private_key }
  suspended_at        { |attrs| attrs[:suspended] ? Time.now.utc : nil }
end
